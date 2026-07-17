#include "Readers/RamReader.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

namespace jozet {

RamData RamReader::readData() {
    RamData data;
    QFile file("/proc/meminfo");
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Error: No se pudo abrir /proc/meminfo";
        return data;
    }

    QTextStream in(&file);
    long memTotal = 0, memAvailable = 0;
    long swapTotal = 0, swapFree = 0;

    QString line;
    while (!in.atEnd()) {
        line = in.readLine().trimmed();

        if (line.startsWith("MemTotal:")) {
            memTotal = line.section(' ', 1, 1).toLong();
        }
        else if (line.startsWith("MemAvailable:")) {
            memAvailable = line.section(' ', 1, 1).toLong();
        }
        else if (line.startsWith("SwapTotal:")) {
            swapTotal = line.section(' ', 1, 1).toLong();
        }
        else if (line.startsWith("SwapFree:")) {
            swapFree = line.section(' ', 1, 1).toLong();
        }
    }

    file.close();

    if (memTotal > 0) {
        data.totalMB = memTotal / 1024;
        long used = memTotal - memAvailable;
        data.usedMB = used / 1024;
        data.usagePercent = qRound((static_cast<double>(used) / memTotal) * 100.0);
    } else {
        qDebug() << "Warning: MemTotal no encontrado en /proc/meminfo";
    }

    if (swapTotal > 0) {
        data.swapTotalMB = swapTotal / 1024;
        long swapUsed = swapTotal - swapFree;
        data.swapUsedMB = swapUsed / 1024;
        data.swapUsagePercent = qRound((static_cast<double>(swapUsed) / swapTotal) * 100.0);
    }

    return data;
}

}