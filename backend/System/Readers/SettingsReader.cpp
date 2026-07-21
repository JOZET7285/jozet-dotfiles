#include "Readers/SettingsReader.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

namespace jozet {

static const QVariantMap DEFAULTS = {
    {"system", QVariantMap{
        {"keyboard_layout", "latam"},
        {"timezone", "America/Mexico_City"},
        {"clock_24h", true}
    }},
    {"connections", QVariantMap{
        {"network", QVariantMap{
            {"wifi_enabled", true},
            {"airplane_mode", false}
        }},
        {"bluetooth", QVariantMap{
            {"enabled", true},
            {"discoverable", false}
        }},
        {"usb", QVariantMap{
            {"auto_mount", true},
            {"notify_on_connect", true}
        }}
    }},
    {"display", QVariantMap{
        {"lockscreen", QVariantMap{
            {"blur", true},
            {"timeout_min", 5},
            {"notifications", false}
        }},
        {"notifications", QVariantMap{
            {"do_not_disturb", false}
        }}
    }},
    {"energy", QVariantMap{
        {"active_profile", "balanced"},
        {"profiles", QVariantMap{
            {"saver", QVariantMap{
                {"brightness", 60},
                {"screen_timeout_min", 4},
                {"suspend_timeout_min", 10}
            }},
            {"balanced", QVariantMap{
                {"brightness", 80},
                {"screen_timeout_min", 5},
                {"suspend_timeout_min", 15}
            }},
            {"perform", QVariantMap{
                {"brightness", 100},
                {"screen_timeout_min", 8},
                {"suspend_timeout_min", 20}
            }}
        }}
    }},
    {"theme", QVariantMap{
        {"mode", "dark"},
        {"accent_color", "#89b4fa"},
        {"wallpaper_path", "~/Pictures/wallpaper.png"},
        {"font", "JetBrains Mono"},
        {"hyprland", QVariantMap{
            {"gaps_in", 5},
            {"gaps_out", 10},
            {"border_radius", 8},
            {"border_size", 2}
        }}
    }}
};

SettingsReader::SettingsReader(QObject *parent) : QObject(parent) {
    m_filePath = QDir::homePath() + "/.config/jozet/rice-settings.json";
    load();
}

QVariantMap SettingsReader::settings() const {
    return m_settings;
}

void SettingsReader::load() {
    QFile file(m_filePath);

    if (!file.exists()) {
        QDir().mkpath(QFileInfo(m_filePath).absolutePath());
        m_settings = DEFAULTS;
        save();
        return;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "SettingsReader: no se pudo leer" << m_filePath;
        m_settings = DEFAULTS;
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    if (doc.isNull() || !doc.isObject()) {
        qWarning() << "SettingsReader: JSON inválido, usando defaults";
        m_settings = DEFAULTS;
        return;
    }

    m_settings = doc.object().toVariantMap();

    // Rellenar keys faltantes con defaults (recursivo)
    mergeDefaults(m_settings, DEFAULTS);
}

void SettingsReader::mergeDefaults(QVariantMap &target, const QVariantMap &defaults) {
    for (auto it = defaults.constBegin(); it != defaults.constEnd(); ++it) {
        if (!target.contains(it.key())) {
            target[it.key()] = it.value();
        } else if (it.value().typeId() == QMetaType::QVariantMap &&
                   target[it.key()].typeId() == QMetaType::QVariantMap) {
            QVariantMap targetSection = target[it.key()].toMap();
            mergeDefaults(targetSection, it.value().toMap());
            target[it.key()] = targetSection;
        }
    }
}

void SettingsReader::save() {
    QDir().mkpath(QFileInfo(m_filePath).absolutePath());

    QFile file(m_filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "SettingsReader: no se pudo escribir" << m_filePath;
        return;
    }

    QJsonDocument doc(QJsonObject::fromVariantMap(m_settings));
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
}

QVariant SettingsReader::get(const QString &key) const {
    QStringList parts = key.split('.');
    if (parts.isEmpty()) return QVariant();

    QVariant current = m_settings;
    for (const QString &part : parts) {
        if (current.typeId() != QMetaType::QVariantMap)
            return QVariant();
        current = current.toMap().value(part);
    }
    return current;
}

bool SettingsReader::setKey(QVariantMap &map, const QString &key, const QVariant &value) {
    int dot = key.indexOf('.');
    if (dot == -1) {
        if (map.contains(key) && map[key] == value)
            return false;
        map[key] = value;
        return true;
    }

    QString section = key.left(dot);
    QString rest = key.mid(dot + 1);

    QVariantMap sectionMap = map.value(section).toMap();
    bool changed = setKey(sectionMap, rest, value);
    if (changed) {
        map[section] = sectionMap;
    }
    return changed;
}

void SettingsReader::set(const QString &key, const QVariant &value) {
    if (setKey(m_settings, key, value)) {
        m_settings = QVariantMap(m_settings);
        save();
        emit settingsChanged();
        emit settingChanged(key, value);
    }
}

void SettingsReader::reset() {
    m_settings = DEFAULTS;
    save();
    emit settingsChanged();
}

}
