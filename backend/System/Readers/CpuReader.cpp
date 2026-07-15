#include "Readers/CpuReader.h"
#include <QFile>
#include <QTextStream>
#include <QStringList>
#include <QRegularExpression>

namespace jozet {

CpuReader::CpuReader() : m_previousTotal(0), m_previousIdle(0) {}

int CpuReader::readUsagePercent() {
    QFile file("/proc/stat");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;

    QTextStream in(&file);
    QString line = in.readLine();
    file.close();

    if (!line.startsWith("cpu "))
        return 0;

    QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
    if (parts.size() < 8)
        return 0;

    long user = parts[1].toLong();
    long nice = parts[2].toLong();
    long system = parts[3].toLong();
    long idle = parts[4].toLong();
    long iowait = parts[5].toLong();
    long irq = parts[6].toLong();
    long softirq = parts[7].toLong();
    long steal = parts[8].toLong();

    long totalIdle = idle + iowait;
    long totalNonIdle = user + nice + system + irq + softirq + steal;
    long total = totalIdle + totalNonIdle;

    long totalDiff = total - m_previousTotal;
    long idleDiff = totalIdle - m_previousIdle;

    m_previousTotal = total;
    m_previousIdle = totalIdle;

    if (totalDiff == 0)
        return 0;

    double percent = (static_cast<double>(totalDiff - idleDiff) / totalDiff) * 100.0;
    
    return qBound(0, qRound(percent), 100);
}

int CpuReader::readCurrentFrequency() {
    QFile file("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;

    QTextStream in(&file);
    QString freqStr = in.readLine();
    file.close();

    return freqStr.toInt() / 1000;
}

}