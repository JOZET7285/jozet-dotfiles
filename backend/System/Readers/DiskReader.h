#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <functional>

namespace jozet {

class DiskReader {
public:
    DiskReader();
    void getHomeFoldersUsageAsync(std::function<void(QVariantList)> onFinished);
    void getMaintenanceInfoAsync(std::function<void(QVariantMap)> onFinished);

    double readUsagePercent(const QString &path);
    qint64 calculateDirSize(const QString &path);
    QVariantList getPartitionsStatus();
    QVariantMap getDiskHealthAndIO();

private:
    qint64 m_lastTimeMs;
    qint64 m_lastReadSectors;
    qint64 m_lastWriteSectors;
    
    void runCommandAsync(const QString& command, const QStringList& args, std::function<void(QString)> callback);
};

}