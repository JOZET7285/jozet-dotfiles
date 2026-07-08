#include "Readers/CpuReader.h"
#include <QFile>
#include <QTextStream>
#include <QStringList>
#include <QRegularExpression>

namespace jozet {

int CpuReader::readUsagePercent() {
    QFile file("/proc/stat");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    QStringList lines = content.split('\n');

    for (const QString &line : lines) {
        if (line.startsWith("cpu ")) {
            QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
            if (parts.size() < 9)
                return 0;

            long user    = parts[1].toLong();
            long nice    = parts[2].toLong();
            long system  = parts[3].toLong();
            long idle    = parts[4].toLong();
            long iowait  = parts[5].toLong();
            long irq     = parts[6].toLong();
            long softirq = parts[7].toLong();
            long steal   = parts[8].toLong();

            long idleTime = idle + iowait;
            long total = user + nice + system + idle + iowait + irq + softirq + steal;

            long idleDelta = idleTime - m_prevIdle;
            long totalDelta = total - m_prevTotal;

            int result = 0;
            if (totalDelta > 0) {
                double percent = (1.0 - (double)idleDelta / totalDelta) * 100.0;
                result = qRound(percent);
            }

            m_prevIdle = idleTime;
            m_prevTotal = total;

            return result;
        }
    }
    return 0;
}

}