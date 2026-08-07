#include "Readers/HardwareReader.h"
#include <QFile>
#include <QProcess>
#include <QRegularExpression>
#include <QSet>
#include <QSysInfo>
#include <QTextStream>
#include <thread>
#include <sys/utsname.h>
#include <QDir>
#include <pwd.h>
#include <unistd.h>

namespace jozet {

static QString readFileTrimmed(const QString &path) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();
    return QString::fromUtf8(file.readAll()).trimmed();
}

HardwareReader::HardwareReader(QObject *parent) : QObject(parent) {
    fetch();
}

QVariantMap HardwareReader::systemInfo() const {
    return m_info;
}

void HardwareReader::refresh() {
    fetch();
}

void HardwareReader::fetch() {
    QVariantMap info;

    readOsAndKernel(info);
    readCpu(info);
    readMemoryTotal(info);
    readMotherboard(info);
    readGpu(info);
    readUserAndShell(info);
    readWindowManager(info);

    if (m_info != info) {
        m_info = info;
        emit systemInfoChanged();
    }
}

void HardwareReader::readOsAndKernel(QVariantMap &info) {
    QFile file("/etc/os-release");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("PRETTY_NAME=")) {
                QString value = line.mid(QString("PRETTY_NAME=").length());
                value.remove('"');
                info["os"] = value;
                break;
            }
        }
    }

    struct utsname uts;
    if (uname(&uts) == 0) {
        info["kernel"] = QString::fromUtf8(uts.release);
        info["arch"] = QString::fromUtf8(uts.machine);
    }

    info["hostname"] = QSysInfo::machineHostName();
}

void HardwareReader::readCpu(QVariantMap &info) {
    QFile file("/proc/cpuinfo");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        const QString content = QString::fromUtf8(file.readAll());
        const QStringList lines = content.split('\n');

        for (const QString &line : lines) {
            if (line.startsWith("model name")) {
                int colon = line.indexOf(':');
                if (colon != -1)
                    info["cpu"] = line.mid(colon + 1).trimmed();
                break;
            }
        }
    }

    QString maxFreqKhz = readFileTrimmed("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq");
    if (!maxFreqKhz.isEmpty()) {
        double ghz = maxFreqKhz.toDouble() / 1000000.0;
        info["cpuFreq"] = QString::number(ghz, 'f', 2) + " GHz";
    }

    QSet<QString> physicalCoreIds;
    int logicalCount = 0;

    QDir cpuDir("/sys/devices/system/cpu");
    const QStringList cpuEntries = cpuDir.entryList(QStringList() << "cpu[0-9]*", QDir::Dirs);

    for (const QString &entry : cpuEntries) {
        QString base = "/sys/devices/system/cpu/" + entry + "/topology/";
        QString pkg = readFileTrimmed(base + "physical_package_id");
        QString core = readFileTrimmed(base + "core_id");

        if (!core.isEmpty()) {
            physicalCoreIds.insert(pkg + ":" + core);
            logicalCount++;
        }
    }

    if (logicalCount == 0)
        logicalCount = static_cast<int>(std::thread::hardware_concurrency());

    info["cpuCores"] = QString::number(physicalCoreIds.isEmpty()
                            ? logicalCount 
                            : physicalCoreIds.size())
                        + "C / " + QString::number(logicalCount) + "T";
}

void HardwareReader::readMemoryTotal(QVariantMap &info) {
    QFile file("/proc/meminfo");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    const QString content = QString::fromUtf8(file.readAll());
    const QStringList lines = content.split('\n');

    for (const QString &line : lines) {
        if (line.startsWith("MemTotal:")) {
            QRegularExpression re("(\\d+)");
            auto match = re.match(line);
            if (match.hasMatch()) {
                qint64 kb = match.captured(1).toLongLong();
                info["ramTotal"] = QString::number(kb / (1024.0 * 1024.0), 'f', 1) + " GB";
            }
            break;
        }
    }
}

void HardwareReader::readMotherboard(QVariantMap &info) {
    QString vendor = readFileTrimmed("/sys/class/dmi/id/board_vendor");
    QString name = readFileTrimmed("/sys/class/dmi/id/board_name");
    QString biosVersion = readFileTrimmed("/sys/class/dmi/id/bios_version");
    QString biosDate = readFileTrimmed("/sys/class/dmi/id/bios_date");

    if (!vendor.isEmpty() || !name.isEmpty())
        info["motherboard"] = (vendor + " " + name).trimmed();

    if (!biosVersion.isEmpty())
        info["bios"] = biosVersion + (biosDate.isEmpty() ? "" : " (" + biosDate + ")");
}

void HardwareReader::readUserAndShell(QVariantMap &info) {
    struct passwd *pw = getpwuid(geteuid());
    if (pw) {
        info["username"] = QString::fromLocal8Bit(pw->pw_name);
        info["shell"] = QString::fromLocal8Bit(pw->pw_shell);
    }
}

void HardwareReader::readWindowManager(QVariantMap &info) {
    // Hyprland is a hard requirement of this rice, so this doesn't need to be
    // generic — no point detecting a WM that will never be running here.
    if (qEnvironmentVariableIsSet("HYPRLAND_INSTANCE_SIGNATURE")) {
        QProcess process;
        process.start("hyprctl", {"version"});
        QString wmVersion = "Hyprland";
        if (process.waitForFinished(500)) {
            QString output = QString::fromUtf8(process.readAllStandardOutput());
            QRegularExpression re("Hyprland (v[\\d.]+)");
            auto match = re.match(output);
            if (match.hasMatch())
                wmVersion = "Hyprland " + match.captured(1);
        }
        info["wm"] = wmVersion;
        info["protocol"] = "Wayland";
    }
}

void HardwareReader::readGpu(QVariantMap &info) {
    QProcess process;
    process.start("lspci", {"-mm"});
    if (!process.waitForFinished(1000))
        return;

    const QString output = QString::fromUtf8(process.readAllStandardOutput());
    const QStringList lines = output.split('\n', Qt::SkipEmptyParts);

    QRegularExpression quoted("\"([^\"]*)\"");

    for (const QString &line : lines) {
        if (!line.contains("VGA compatible controller") && !line.contains("3D controller"))
            continue;

        QStringList fields;
        auto it = quoted.globalMatch(line);
        while (it.hasNext())
            fields << it.next().captured(1);

        if (fields.size() >= 3) {
            info["gpuVendor"] = fields[1];
            info["gpu"] = fields[2];
        }
        break;
    }
}

}