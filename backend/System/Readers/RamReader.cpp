#include "Readers/RamReader.h"
#include <QFile>
#include <QStringList>
#include <QDebug>
#include <cmath>

namespace jozet {

RamData RamReader::readData() {
    RamData data;
    data.totalMB = 0;
    data.usedMB = 0;
    data.usagePercent = 0.0;
    data.swapTotalMB = 0;
    data.swapUsedMB = 0;
    data.swapUsagePercent = 0.0;

    QFile file("/proc/meminfo");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        
        QString content = QString::fromUtf8(file.readAll());
        file.close();

        if (content.isEmpty()) {
            return data;
        }

        long long memTotal = 0;
        long long memAvailable = 0;
        long long swapTotal = 0;
        long long swapFree = 0;
        
        QStringList lines = content.split('\n', Qt::SkipEmptyParts);
        for (const QString& line : lines) {
            if (line.startsWith("MemTotal:")) {
                QStringList parts = line.split(' ', Qt::SkipEmptyParts);
                if (parts.size() >= 2) memTotal = parts[1].toLongLong();
            } 
            else if (line.startsWith("MemAvailable:")) {
                QStringList parts = line.split(' ', Qt::SkipEmptyParts);
                if (parts.size() >= 2) memAvailable = parts[1].toLongLong();
            }
            else if (line.startsWith("SwapTotal:")) {
                QStringList parts = line.split(' ', Qt::SkipEmptyParts);
                if (parts.size() >= 2) swapTotal = parts[1].toLongLong();
            }
            else if (line.startsWith("SwapFree:")) {
                QStringList parts = line.split(' ', Qt::SkipEmptyParts);
                if (parts.size() >= 2) swapFree = parts[1].toLongLong();
            }
        }

        if (memTotal > 0) {
            data.totalMB = memTotal / 1024;
            long long used = memTotal - memAvailable;
            data.usedMB = used / 1024;
            data.usagePercent = std::round((static_cast<double>(used) / memTotal) * 1000.0) / 10.0;
        }

        if (swapTotal > 0) {
            data.swapTotalMB = swapTotal / 1024;
            long long swapUsed = swapTotal - swapFree;
            data.swapUsedMB = swapUsed / 1024;
            data.swapUsagePercent = std::round((static_cast<double>(swapUsed) / swapTotal) * 1000.0) / 10.0; 
        }
    }
    
    return data;
}

}