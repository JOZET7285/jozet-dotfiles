#include "Readers/RamReader.h"
#include <QFile>
#include <QTextStream>
#include <QStringList>
#include <QRegularExpression>

namespace jozet {

int RamReader::readUsagePercent() {
    QFile file("/proc/meminfo");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    QStringList lines = content.split('\n');

    long memTotal = 0;
    long memAvailable = 0;

    for (const QString &line : lines) {
        if (line.startsWith("MemTotal:")) {
            memTotal = line.split(QRegularExpression("\\s+"))[1].toLong();
        } else if (line.startsWith("MemAvailable:")) {
            memAvailable = line.split(QRegularExpression("\\s+"))[1].toLong();
        }
    }

    if (memTotal == 0)
        return 0;

    double used = memTotal - memAvailable;
    double percent = (used / memTotal) * 100.0;
    return qRound(percent);
}

}