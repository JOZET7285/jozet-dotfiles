#include "Readers/ProcessReader.h"
#include <QProcess>
#include <QStringList>
#include <QVariantMap>
#include <QThread>

namespace jozet {

QVariantList ProcessReader::readTopRamProcesses(int limit) {
    QVariantList processList;
    QProcess process;

    process.start("ps", QStringList() << "axo" << "comm,rss" << "--sort=-rss" << "--no-headers");
    process.waitForFinished();

    QString output = process.readAllStandardOutput();
    QStringList lines = output.split('\n', Qt::SkipEmptyParts);

    int count = 0;
    for (const QString &line : lines) {
        if (count >= limit) break;

        QStringList parts = line.simplified().split(' ');
        
        if (parts.size() >= 2) {
            QVariantMap processData;
            
            long rssKb = parts.last().toLong();
            QString name = parts.mid(0, parts.size() - 1).join(" ");

            processData["name"] = name;
            processData["memoryMB"] = static_cast<qint64>(rssKb / 1024);            
            
            processList.append(processData);
            count++;
        }
    }

    return processList;
}

QVariantList ProcessReader::readTopCpuProcesses(int limit) {
    QVariantList processList;
    QProcess process;
    
    process.start("ps", QStringList() << "axo" << "comm,pcpu" << "--sort=-pcpu" << "--no-headers");
    process.waitForFinished();

    QString output = process.readAllStandardOutput();
    QStringList lines = output.split('\n', Qt::SkipEmptyParts);

    int coreCount = QThread::idealThreadCount();
    if (coreCount <= 0) coreCount = 1;

    int count = 0;

    for (const QString &line : lines) {
        if (count >= limit) break;

        QStringList parts = line.simplified().split(' ');
        
        if (parts.size() >= 2) {
            QString name = parts.mid(0, parts.size() - 1).join(" ");
            if (name == "ps") continue;

            // Leer porcentaje crudo y normalizarlo al total del sistema
            double rawCpuPercent = parts.last().toDouble();
            double normalizedCpuPercent = rawCpuPercent / coreCount;

            QVariantMap processData;
            processData["name"] = name;
            processData["usagePercent"] = QString::number(normalizedCpuPercent, 'f', 1);
            
            processList.append(processData);
            count++;
        }
    }

    return processList;
}

}