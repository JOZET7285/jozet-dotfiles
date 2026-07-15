#include "Readers/RamReader.h"
#include <QFile>
#include <QTextStream>
#include <QStringList>
#include <QRegularExpression>

namespace jozet {

RamData RamReader::readData() {
    RamData data;
    QFile file("/proc/meminfo");
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return data;

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    QStringList lines = content.split("\n");

    long memTotal = 0, memAvailable = 0;
    long swapTotal = 0, swapFree = 0;

    // Extracción de datos en una sola pasada
    for (const QString &line : lines) {
        if (line.startsWith("MemTotal:")) {
            memTotal = line.split(QRegularExpression("\\s+"))[1].toLong();
        } else if (line.startsWith("MemAvailable:")) {
            memAvailable = line.split(QRegularExpression("\\s+"))[1].toLong();
        } else if (line.startsWith("SwapTotal:")) {
            swapTotal = line.split(QRegularExpression("\\s+"))[1].toLong();
        } else if (line.startsWith("SwapFree:")) {
            swapFree = line.split(QRegularExpression("\\s+"))[1].toLong();
        }
    }

    if (memTotal > 0) {
        data.totalMB = memTotal / 1024;
        long used = memTotal - memAvailable;
        data.usedMB = used / 1024;
        data.usagePercent = qRound((static_cast<double>(used) / memTotal) * 100.0);
    }

    // Cálculos de Swap (Convirtiendo kB a MB)
    if (swapTotal > 0) {
        data.swapTotalMB = swapTotal / 1024;
        long swapUsed = swapTotal - swapFree;
        data.swapUsedMB = swapUsed / 1024;
        data.swapUsagePercent = qRound((static_cast<double>(swapUsed) / swapTotal) * 100.0);
    }

    return data;
}

}