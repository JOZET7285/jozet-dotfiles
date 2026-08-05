#include "Readers/HyprlandWriter.h"
#include "Readers/SettingsReader.h"
#include "Readers/MatugenReader.h"
#include <QDebug>
#include <QProcess>

namespace jozet {

static const QHash<QString, QString> SETTING_MAP = {
    {"theme.hyprland.gaps_in", "general:gaps_in"},
    {"theme.hyprland.gaps_out", "general:gaps_out"},
    {"theme.hyprland.border_radius", "decoration:rounding"},
    {"theme.hyprland.border_size", "general:border_size"},
    {"system.keyboard_layout", "input:kb_layout"},
    {"theme.cursor.speed", "input:sensitivity"},
};

HyprlandWriter::HyprlandWriter(SettingsReader *reader, MatugenReader *matugen, QObject *parent)
    : QObject(parent), m_reader(reader), m_matugen(matugen) {
    applyAll();
    connect(m_reader, &SettingsReader::settingChanged, this, [this](const QString &key, const QVariant &value) {
        applySetting(key, value);
    });
}

static QString escapeLua(const QString &s) {
    QString out = s;
    return out.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
}

void HyprlandWriter::applyAll() {
    auto s = m_reader->settings();

    auto theme = s.value("theme").toMap();
    auto hyprland = theme.value("hyprland").toMap();
    auto cursor = theme.value("cursor").toMap();
    auto system = s.value("system").toMap();

    double speed = cursor.value("speed", 1.0).toDouble();
    if (speed <= 0.0)
        speed = 1.0;

    QString lua = QString("hl.config({general={gaps_in=%1,gaps_out=%2,border_size=%3},decoration={rounding=%4},input={kb_layout=\"%5\",sensitivity=%6}})")
        .arg(hyprland.value("gaps_in", 5).toInt())
        .arg(hyprland.value("gaps_out", 10).toInt())
        .arg(hyprland.value("border_size", 2).toInt())
        .arg(hyprland.value("border_radius", 8).toInt())
        .arg(escapeLua(system.value("keyboard_layout", "latam").toString()))
        .arg(speed);

    QProcess proc;
    proc.start("hyprctl", {"eval", lua});
    proc.waitForFinished(3000);

    applyCursorTheme();
    applyBorderColors();
    writeLuaDataFile();
    restartHypridle();
}

void HyprlandWriter::applyCursorTheme()
{
    auto cursor = m_reader->settings().value("theme").toMap().value("cursor").toMap();

    QString theme = cursor.value("theme").toString().trimmed();
    if (theme.isEmpty())
        return;

    int size = cursor.value("size", 24).toInt();
    if (size < 4)
        size = 4;
    if (size > 128)
        size = 128;

    QProcess proc;
    proc.start("hyprctl", {"setcursor", theme, QString::number(size)});
    proc.waitForFinished(3000);
}

QString HyprlandWriter::accentColor() const
{
    return m_matugen ? m_matugen->colors().value("accent").toString() : QString();
}

QString HyprlandWriter::toHyprColor(const QString &hex, const QString &alpha) const
{
    QString c = hex.trimmed();
    if (c.startsWith('#'))
        c = c.mid(1);
    return "0x" + alpha + c;
}

void HyprlandWriter::applyBorderColors()
{
    QString accent = accentColor();
    if (accent.isEmpty())
        return;

    QString active = toHyprColor(accent);
    QString inactive = toHyprColor(accent, "40");

    QString lua = QString("hl.config({general={[\"col.active_border\"]=\"%1\",[\"col.inactive_border\"]=\"%2\"}})")
        .arg(active, inactive);

    QProcess proc;
    proc.start("hyprctl", {"eval", lua});
    proc.waitForFinished(3000);
}

void HyprlandWriter::applyColorScheme()
{
    applyBorderColors();
    writeLuaDataFile();
}

void HyprlandWriter::applySetting(const QString &key, const QVariant &value) {
    if (key == "theme.cursor.theme" || key == "theme.cursor.size") {
        applyCursorTheme();
    }
    if (SETTING_MAP.contains(key)) {
        QString kw = SETTING_MAP[key];
        QStringList parts = kw.split(':');
        if (parts.size() == 2) {
            QString valStr = value.toString();
            if (value.typeId() == QMetaType::QString || value.typeId() == QMetaType::QByteArray)
                valStr = "\"" + escapeLua(valStr) + "\"";
            QString lua = QString("hl.config({%1={%2=%3}})")
                .arg(parts[0], parts[1], valStr);
            QProcess proc;
            proc.start("hyprctl", {"eval", lua});
            proc.waitForFinished(3000);
        }
    }

    if (key == "energy.active_profile") {
        restartHypridle();
    }

    writeLuaDataFile();
}

void HyprlandWriter::restartHypridle() {
    auto s = m_reader->settings();
    auto energy = s.value("energy").toMap();
    auto profiles = energy.value("profiles").toMap();
    auto activeKey = energy.value("active_profile", "balanced").toString();
    auto profile = profiles.value(activeKey).toMap();

    int screenSec = profile.value("screen_timeout_min", 5).toInt() * 60;
    int suspendSec = profile.value("suspend_timeout_min", 15).toInt() * 60;

    QString hypridlePath = QDir::homePath() + "/.config/hypr/hypridle.conf";
    QFile file(hypridlePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&file);
        out << "general {\n";
        out << "    lock_cmd = qs ipc call session lock\n";
        out << "    before_sleep_cmd = qs ipc call session lock\n";
        out << "    after_sleep_cmd = hyprctl dispatch dpms on\n";
        out << "}\n\n";
        out << "listener {\n";
        out << "    timeout = " << screenSec << "\n";
        out << "    on-timeout = qs ipc call session lock\n";
        out << "}\n\n";
        out << "listener {\n";
        out << "    timeout = " << suspendSec << "\n";
        out << "    on-timeout = systemctl suspend\n";
        out << "}\n";
        file.close();
    }

    QProcess::execute("killall", {"hypridle"});
    QProcess::startDetached("hypridle");
}

QString HyprlandWriter::luaDataPath() const {
    return QDir::homePath() + "/.local/share/jzt/datos.lua";
}

void HyprlandWriter::writeLuaDataFile() {
    auto s = m_reader->settings();
    auto theme = s.value("theme").toMap();
    auto hyprland = theme.value("hyprland").toMap();
    auto cursor = theme.value("cursor").toMap();
    auto system = s.value("system").toMap();

    double speed = cursor.value("speed", 1.0).toDouble();
    if (speed <= 0.0)
        speed = 1.0;

    QString accent = accentColor();
    QString active = toHyprColor(accent);
    QString inactive = toHyprColor(accent, "40");
    QString activeLine, inactiveLine;
    if (!accent.isEmpty()) {
        activeLine = QString("    active_border = \"%1\",\n").arg(active);
        inactiveLine = QString("    inactive_border = \"%1\",\n").arg(inactive);
    }

    QFile file(luaDataPath());
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&file);
        out << "-- Generado por HyprlandWriter\n";
        out << "return {\n";
        out << "    gaps_in = " << hyprland.value("gaps_in", 5).toInt() << ",\n";
        out << "    gaps_out = " << hyprland.value("gaps_out", 10).toInt() << ",\n";
        out << "    border_radius = " << hyprland.value("border_radius", 8).toInt() << ",\n";
        out << "    border_size = " << hyprland.value("border_size", 2).toInt() << ",\n";
        out << activeLine;
        out << inactiveLine;
        out << "    kb_layout = \"" << system.value("keyboard_layout", "latam").toString() << "\",\n";
        out << "    cursor_theme = \"" << cursor.value("theme", "").toString() << "\",\n";
        out << "    cursor_size = " << cursor.value("size", 24).toInt() << ",\n";
        out << "    cursor_speed = " << speed << ",\n";
        out << "}\n";
        file.close();
    }
}

}
