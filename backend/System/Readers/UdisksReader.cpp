#include "Readers/UdisksReader.h"
#include <QDebug>
#include <QProcess>
#include <QRegularExpression>
#include <QStorageInfo>
#include <cmath>

namespace jozet {

UdisksReader::UdisksReader(QObject *parent) : QObject(parent) {
    m_pollTimer = new QTimer(this);
    connect(m_pollTimer, &QTimer::timeout, this, &UdisksReader::pollDevices);
    m_pollTimer->start(3000);

    pollDevices();
}

QVariantList UdisksReader::devices() const {
    QVariantList list;
    for (const auto &dev : m_devices) {
        QVariantMap map;
        map["path"] = dev.path;
        map["devicePath"] = dev.devicePath;
        map["name"] = dev.name;
        map["size"] = dev.size;
        map["mountPoint"] = dev.mountPoint;
        map["mounted"] = dev.mounted;
        map["percent"] = dev.percent;
        map["totalGb"] = dev.totalGb;
        map["usedGb"] = dev.usedGb;
        list.append(map);
    }
    return list;
}

void UdisksReader::refreshDevices() {
    pollDevices();
}

void UdisksReader::pollDevices() {
    QProcess process;
    process.start("udisksctl", {"dump"});
    process.waitForFinished(3000);

    if (process.exitCode() != 0)
        return;

    QString output = QString::fromUtf8(process.readAllStandardOutput());
    QList<UsbDevice> found;
    static const QRegularExpression blockRe(QStringLiteral("^(/org/freedesktop/UDisks2/block_devices/\\S+):$"));
    static const QRegularExpression propRe(QStringLiteral("^\\s+(\\S[\\w.]+):\\s+(.*)$"));

    UsbDevice current;
    bool inBlock = false;

    for (const QString &line : output.split('\n')) {
        QRegularExpressionMatch blockMatch = blockRe.match(line);
        if (blockMatch.hasMatch()) {
            if (inBlock && !current.path.isEmpty()) {
                found.append(current);
            }
            current = UsbDevice();
            current.path = blockMatch.captured(1);
            current.mounted = false;
            inBlock = true;
            continue;
        }

        if (!inBlock)
            continue;

        if (line.isEmpty() || (!line.startsWith(' ') && !line.startsWith('\t'))) {
            if (!current.path.isEmpty()) {
                found.append(current);
            }
            current = UsbDevice();
            inBlock = false;
            continue;
        }

        QRegularExpressionMatch propMatch = propRe.match(line);
        if (propMatch.hasMatch()) {
            QString key = propMatch.captured(1);
            QString val = propMatch.captured(2).trimmed();

            if (key == "IdUsage") {
                if (val != "filesystem") {
                    current.path.clear();
                }
            } else if (key == "Device") {
                current.devicePath = val;
            } else if (key == "HintAuto" && val != "true") {
                current.path.clear();
            } else if (key == "IdLabel" && !val.isEmpty()) {
                current.name = val;
            } else if (key == "Size") {
                qint64 bytes = val.toLongLong();
                if (bytes >= 1073741824LL)
                    current.size = QString::number(bytes / 1073741824.0, 'f', 1) + " GB";
                else if (bytes >= 1048576LL)
                    current.size = QString::number(bytes / 1048576.0, 'f', 0) + " MB";
                else
                    current.size = val + " B";
            } else if (key == "MountPoints") {
                QString mp = val.trimmed();
                if (!mp.isEmpty() && mp != "[]") {
                    current.mountPoint = mp;
                    current.mounted = true;
                }
            }
        }
    }

    if (inBlock && !current.path.isEmpty()) {
        found.append(current);
    }

    for (auto &dev : found) {
        dev.percent = 0.0;
        dev.totalGb = 0.0;
        dev.usedGb = 0.0;
        if (dev.mounted && !dev.mountPoint.isEmpty()) {
            QStorageInfo storage(dev.mountPoint);
            if (storage.isValid() && storage.isReady()) {
                qint64 total = storage.bytesTotal();
                qint64 available = storage.bytesAvailable();
                dev.totalGb = std::round((total / 1073741824.0) * 10.0) / 10.0;
                dev.usedGb = std::round(((total - available) / 1073741824.0) * 10.0) / 10.0;
                dev.percent = total > 0
                    ? std::round((double)(total - available) / total * 1000.0) / 10.0
                    : 0.0;
            }
        }
    }

    bool changed = (found.size() != m_devices.size());
    if (!changed) {
        for (int i = 0; i < found.size(); ++i) {
            if (found[i].path != m_devices[i].path ||
                found[i].mounted != m_devices[i].mounted ||
                found[i].size != m_devices[i].size) {
                changed = true;
                break;
            }
        }
    }

    if (changed) {
        m_devices = found;
        emit devicesChanged();
    }
}

void UdisksReader::mountDevice(const QString &path) {
    QProcess process;
    process.start("udisksctl", {"mount", "-b", path});
    process.waitForFinished(5000);

    if (process.exitCode() == 0) {
        qDebug() << "Mounted:" << path;
    } else {
        qDebug() << "Mount failed:" << process.readAllStandardError();
    }

    pollDevices();
}

void UdisksReader::unmountDevice(const QString &path) {
    QProcess process;
    process.start("udisksctl", {"unmount", "-b", path});
    process.waitForFinished(5000);

    if (process.exitCode() == 0) {
        qDebug() << "Unmounted:" << path;
    } else {
        qDebug() << "Unmount failed:" << process.readAllStandardError();
    }

    pollDevices();
}

}
