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
    m_lastReadSectors = 0;
    m_lastWriteSectors = 0;
}

double DiskReader::readUsagePercent(const QString &path) {
    QStorageInfo storage(path);
    if (!storage.isValid() || !storage.isReady()) 
        return 0.0;

    qint64 total = storage.bytesTotal();
    if (total == 0) return 0.0;

    qint64 available = storage.bytesAvailable();
    qint64 used = total - available; 

    double percent = (double)used / total * 100.0;
    return std::round(percent * 10.0) / 10.0; 
}

void DiskReader::runCommandAsync(const QString& command, const QStringList& args, std::function<void(QString)> callback) {
    QProcess *process = new QProcess();
    
    QObject::connect(process, &QProcess::finished, [process, callback](int exitCode, QProcess::ExitStatus exitStatus) {
        QString output = process->readAllStandardOutput().trimmed();
        
        if (callback) {
            callback(output);
        }
        
        process->deleteLater();
    });

    process->start(command, args);
}

void DiskReader::getHomeFoldersUsageAsync(std::function<void(QVariantList)> onFinished) {
    QDir homeDir(QDir::homePath());
    homeDir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoSymLinks);
    
    QStringList args;
    args << "-sk"; // Tamaño total, en kilobytes
    
    for (const QFileInfo &fileInfo : homeDir.entryInfoList()) {
        if (!fileInfo.fileName().startsWith(".")) {
            args << fileInfo.absoluteFilePath();
        }
    }

    if (args.size() == 1) {
        if (onFinished) onFinished({});
        return;
    }

    runCommandAsync("du", args, [onFinished](const QString& out) {
        QVariantList foldersList;
        QStringList lines = out.split('\n', Qt::SkipEmptyParts);
        
        for (const QString& line : lines) {
            QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
            if (parts.size() >= 2) {
                long long kb = parts[0].toLongLong();
                double sizeMb = kb / 1024.0;
                
                QString folderPath = parts[1];
                QString folderName = folderPath.mid(folderPath.lastIndexOf('/') + 1);

                QVariantMap folderData;
                folderData["name"] = folderName;
                folderData["sizeMb"] = std::round(sizeMb * 10.0) / 10.0;
                foldersList.append(folderData);
            }
        }

        std::sort(foldersList.begin(), foldersList.end(), [](const QVariant &a, const QVariant &b) {
            return a.toMap()["sizeMb"].toDouble() > b.toMap()["sizeMb"].toDouble();
        });

        if (onFinished) onFinished(foldersList);
    });
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

void DiskReader::getMaintenanceInfoAsync(std::function<void(QVariantMap)> onFinished) {
    QString cachePath = QDir::homePath() + "/.cache";
    QString trashPath = QDir::homePath() + "/.local/share/Trash";
    QString logsPath = "/var/log";

    QStringList args = {"-sk", cachePath, trashPath, logsPath};
    
    runCommandAsync("du", args, [cachePath, trashPath, logsPath, onFinished](const QString& out) {
        QVariantMap mainData;
        mainData["cacheMb"] = 0.0;
        mainData["trashMb"] = 0.0;
        mainData["logsMb"]  = 0.0;

        QStringList lines = out.split('\n', Qt::SkipEmptyParts);
        for (const QString& line : lines) {
            QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
            if (parts.size() >= 2) {
                long long kb = parts[0].toLongLong();
                double mb = std::round((kb / 1024.0) * 10.0) / 10.0;
                
                if (parts[1] == cachePath) mainData["cacheMb"] = mb;
                else if (parts[1] == trashPath) mainData["trashMb"] = mb;
                else if (parts[1] == logsPath) mainData["logsMb"] = mb;
            }
        }
        
        if (onFinished) onFinished(mainData);
    });
}

} // namespace jozet