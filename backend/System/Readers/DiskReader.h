#pragma once
#include <QString>
#include <QVariantList>
#include <QVariantMap>

namespace jozet {
    class DiskReader {
    public:
        DiskReader();
        
        double readUsagePercent(const QString &path);
        QVariantList getHomeFoldersUsage(); 
        QVariantList getPartitionsStatus(); 
        QVariantMap getDiskHealthAndIO();   
        QVariantMap getMaintenanceInfo();

    private:
        qint64 calculateDirSize(const QString &path);

        qint64 m_lastReadSectors = 0;
        qint64 m_lastWriteSectors = 0;
        qint64 m_lastTimeMs = 0;
    };
}