#include "Readers/StatsReader.h"
#include <QFile>
#include <QProcess>
#include <QStringList>
#include <QSet>

namespace jozet {
    static const QSet<QString> ignoredProcesses = {
        "hyprland", "systemd", "dbus-broker", "pipewire-pulse",
        "networkmanager", "wireplumber", "pipewire", "playerctl",
        "rcu_preempt", "irq/79-rtw89_pc", "irq/70-elan072b",
        "webextensions", "swayosd-libinpu", "polkitd",
        "isolated web co", "xdg-desktop-por", "electron",
        "bluetoothd", "upowerd", "power-profiles-"
    };

    QVariantMap StatsReader::readStats() {
        QVariantMap stats;
        stats["uptime"] = getUptime();
        stats["mostUsedApps"] = getMostUsedApps();
        return stats;
    }

    QString StatsReader::getUptime() {
        QFile file("/proc/uptime");
        if (file.open(QIODevice::ReadOnly)) {
            double uptimeSeconds = QString(file.readAll().split(' ').first()).toDouble();
            int hours = uptimeSeconds / 3600;
            int minutes = (static_cast<int>(uptimeSeconds) % 3600) / 60;
            return QString("%1h %2m").arg(hours).arg(minutes);
        }
        return "0h 0m";
    }

    QVariantList StatsReader::getMostUsedApps() {
        QVariantList apps;
        QProcess process;
        
        QString cmd = "ps -eo comm,time | grep -v 'COMMAND' | grep -v 'ps'";
        process.start("/bin/sh", {"-c", cmd});
        
        if (process.waitForFinished(1000)) {
            QStringList lines = QString(process.readAllStandardOutput()).split('\n', Qt::SkipEmptyParts);
            
            QMap<QString, int> appTimes;
            
            for (const QString &line : lines) {
                QStringList parts = line.simplified().split(' ');
                if (parts.size() >= 2) {
                    QString name = parts[0];
                    QString timeStr = parts[1];

                    if (ignoredProcesses.contains(name.toLower())) {
                        continue;
                    }
                    
                    int seconds = 0;
                    QString t = timeStr;
                    int days = 0;
                    
                    if (t.contains('-')) {
                        QStringList dParts = t.split('-');
                        days = dParts[0].toInt();
                        t = dParts[1];
                    }
                    
                    QStringList hms = t.split(':');
                    if (hms.size() == 3) {
                        seconds = hms[0].toInt() * 3600 + hms[1].toInt() * 60 + hms[2].toInt();
                    } else if (hms.size() == 2) {
                        seconds = hms[0].toInt() * 60 + hms[1].toInt();
                    }
                    
                    seconds += days * 86400;
                    appTimes[name] += seconds;
                }
            }
            
            QList<QPair<int, QString>> sortedApps;
            for (auto it = appTimes.begin(); it != appTimes.end(); ++it) {
                sortedApps.append(qMakePair(it.value(), it.key()));
            }
            std::sort(sortedApps.begin(), sortedApps.end(), std::greater<QPair<int, QString>>());
            
            int count = 0;
            for (const auto &pair : sortedApps) {
                if (count >= 4) break;
                if (pair.first == 0) continue;
                
                QVariantMap appData;
                appData["name"] = pair.second;
                
                int h = pair.first / 3600;
                int m = (pair.first % 3600) / 60;
                int s = pair.first % 60;
                
                appData["time"] = QString("%1:%2:%3")
                                    .arg(h, 2, 10, QChar('0'))
                                    .arg(m, 2, 10, QChar('0'))
                                    .arg(s, 2, 10, QChar('0'));
                
                apps.append(appData);
                count++;
            }
        }
        return apps;
    }
}