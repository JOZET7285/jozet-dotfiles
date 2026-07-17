#include "Readers/DiskReader.h"
#include <QStorageInfo>
#include <cmath>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QRegularExpression>
#include <algorithm>
#include <QProcess>

namespace jozet {

DiskReader::DiskReader() {
    m_lastTimeMs = QDateTime::currentMSecsSinceEpoch();
}

double DiskReader::readUsagePercent(const QString &path) {
    QStorageInfo storage(path);
    if (!storage.isValid() || !storage.isReady()) 
        return 0.0;

    qint64 total = storage.bytesTotal();
    qint64 available = storage.bytesAvailable();
    return total > 0 ? std::round((double)(total - available) / total * 1000.0) / 10.0 : 0.0;
}

qint64 DiskReader::calculateDirSize(const QString &path) {
    if (!QDir(path).exists()) return 0;

    QProcess process;
    process.start("du", {"-s", "--block-size=1M", path});
    process.waitForFinished(1500); // 1.5 segundos máximo

    if (process.exitCode() == 0) {
        QString output = process.readAllStandardOutput().trimmed();
        return output.section('\t', 0, 0).toLongLong() * 1024LL * 1024LL;
    }
    return 0;
}

QVariantList DiskReader::getHomeFoldersUsage() {
    QVariantList list;
    QString home = QDir::homePath();
    QStringList dirs {"Downloads", "Documents", "Pictures", "Videos", "Music", ".config", ".local"};

    for (const QString &d : dirs) {
        QString path = home + "/" + d;
        if (!QDir(path).exists()) continue;

        qint64 bytes = calculateDirSize(path);
        QVariantMap item;
        item["name"] = d;
        item["sizeMb"] = std::round(bytes / (1024.0 * 1024.0) * 10.0) / 10.0;
        list.append(item);
    }

    std::sort(list.begin(), list.end(), [](const QVariant &a, const QVariant &b){
        return a.toMap()["sizeMb"].toDouble() > b.toMap()["sizeMb"].toDouble();
    });

    return list;
}

QVariantList DiskReader::getPartitionsStatus() {
    QVariantList partitions;
    for (const QStorageInfo &storage : QStorageInfo::mountedVolumes()) {
        if (storage.isValid() && storage.isReady()) {
            QString path = storage.rootPath();
            if (path == "/" || path == "/home" || path.startsWith("/run/media")) {
                qint64 total = storage.bytesTotal();
                qint64 available = storage.bytesAvailable();
                
                QVariantMap pData;
                pData["path"] = path;
                pData["totalGb"] = std::round((total / 1073741824.0) * 10.0) / 10.0;
                pData["usedGb"]  = std::round(((total - available) / 1073741824.0) * 10.0) / 10.0;
                pData["percent"] = readUsagePercent(path);
                partitions.append(pData);
            }
        }
    }
    return partitions;
}

QVariantMap DiskReader::getDiskHealthAndIO() {
    QVariantMap ioData;
    ioData["readSpeedMb"] = 0.0;
    ioData["writeSpeedMb"] = 0.0;
    ioData["health"] = "OK";
    
    QFile file("/proc/diskstats");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        qint64 currentRead = 0;
        qint64 currentWrite = 0;

        static const QRegularExpression spaceRegex("\\s+");

        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.contains("sda ") || line.contains("nvme0n1 ")) {
                QStringList parts = line.split(spaceRegex, Qt::SkipEmptyParts);
                if (parts.size() >= 13) {
                    currentRead += parts[5].toLongLong();
                    currentWrite += parts[9].toLongLong();
                }
            }
        }

        qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
        double timeDiffSec = (currentTime - m_lastTimeMs) / 1000.0;

        if (timeDiffSec > 0 && m_lastTimeMs > 0) {
            double readBytesPerSec = ((currentRead - m_lastReadSectors) * 512.0) / timeDiffSec;
            double writeBytesPerSec = ((currentWrite - m_lastWriteSectors) * 512.0) / timeDiffSec;

            ioData["readSpeedMb"] = std::round((readBytesPerSec / 1048576.0) * 10.0) / 10.0;
            ioData["writeSpeedMb"] = std::round((writeBytesPerSec / 1048576.0) * 10.0) / 10.0;
        }

        m_lastReadSectors = currentRead;
        m_lastWriteSectors = currentWrite;
        m_lastTimeMs = currentTime;
    }
    return ioData;
}

QVariantMap DiskReader::getMaintenanceInfo() {
    QVariantMap mainData;
    QString home = QDir::homePath();

    mainData["cacheMb"] = std::round(calculateDirSize(home + "/.cache") / 1048576.0 * 10.0) / 10.0;
    mainData["trashMb"] = std::round(calculateDirSize(home + "/.local/share/Trash") / 1048576.0 * 10.0) / 10.0;
    mainData["logsMb"] = 0.0;

    return mainData;
}

} // namespace jozet