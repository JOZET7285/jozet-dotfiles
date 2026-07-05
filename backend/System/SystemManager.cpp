#include "System/SystemManager.h"
#include <QTimer>
#include <QFile>
#include <QString>
#include <QTextStream>
#include <QRegularExpression>
#include <QStorageInfo>
#include <QDir>

namespace jozet {
    SystemManager::SystemManager(QObject *parent)
        : QObject(parent)
    {
        QTimer *timer = new QTimer(this);

        connect(timer, &QTimer::timeout,
                this, &SystemManager::update);

        timer->start(3000);
    }

    int SystemManager::ramUsage() const
    {
        return m_ramUsage;
    }
    int SystemManager::cpuUsage() const
    {
        return m_cpuUsage;
    }
    double SystemManager::diskUsage() const
    {
        return m_diskUsage;
    }
    int SystemManager::cpuTemp() const
    {
        return m_cpuTemp;
    }

    int SystemManager::readCpuTemperature() {
        QFile file("/sys/class/thermal/thermal_zone0/temp");
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
            return 0.0;

        QString line = file.readAll();
        file.close();
        return line.toInt() / 1000.0;
    }
    
    void SystemManager::update() {
        QFile ramFile("/proc/meminfo");
        QFile cpuFile("/proc/stat");

        if (
            !ramFile.open(QIODevice::ReadOnly | QIODevice::Text) ||
            !cpuFile.open(QIODevice::ReadOnly | QIODevice::Text)
        ) {
            return;
        }

        QTextStream ramIn(&ramFile);
        QString ramContent = ramIn.readAll();
        ramFile.close();

        QTextStream cpuIn(&cpuFile);
        QString cpuContent = cpuIn.readAll();
        cpuFile.close();

        QStringList ramLines = ramContent.split('\n');
        QStringList cpuLines = cpuContent.split('\n');

        long memTotal = 0;
        long memAvailable = 0;

        // Lectura de porcentaje de CPU en uso

        for (const QString &line : cpuLines) {
            if (line.startsWith("cpu ")) {
                QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);

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

                if (totalDelta > 0) {
                    double cpuPercent = (1.0 - (double)idleDelta / totalDelta) * 100.0;
                    m_cpuUsage = qRound(cpuPercent);
                    emit cpuUsageChanged();
                }

                m_prevIdle = idleTime;
                m_prevTotal = total;
                
                break;
            }
        }

        // Lectura de porcentaje de ram en uso

        for (const QString &line : ramLines) {
            if (line.startsWith("MemTotal:")){
                memTotal = line.split(QRegularExpression("\\s+"))[1].toLong();
            } else if (line.startsWith("MemAvailable:")){
                memAvailable = line.split(QRegularExpression("\\s+"))[1].toLong();
            }
        }

        if (memTotal == 0) {
            return;
        }

        double ramUsed = memTotal - memAvailable;
        double ramPercent = (ramUsed / memTotal) * 100.0;
        
        m_ramUsage = qRound(ramPercent);

        emit ramUsageChanged();

        // Lectura de porcentaje de espacio en disco
        QStorageInfo storage("/home"); 

        if (storage.isValid() && storage.isReady()) {
            qint64 total = storage.bytesTotal();
            qint64 available = storage.bytesAvailable();
            qint64 used = total - available;

            double diskPercent = (double)used / total * 100.0;
            m_diskUsage = round(diskPercent*10.0) / 10.0;
            emit diskUsageChanged();
        }

        // Lectura de temperatura del procesador 
        m_cpuTemp = readCpuTemperature();
        emit cpuTempChanged();

    }
}