#include "System/SystemManager.h"
#include <QTimer>
#include <QUrl>
#include <QNetworkRequest>
#include <QDebug>
#include <algorithm>
#include <QThread>
#include <QProcess>

namespace jozet {

SystemManager::SystemManager(QObject *parent)
    : QObject(parent)
{
    m_networkManager = new QNetworkAccessManager(this);

    QTimer *timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &SystemManager::update);
    timer->start(3000);

    QTimer *weatherTimer = new QTimer(this);
    connect(weatherTimer, &QTimer::timeout, this, &SystemManager::fetchWeather);
    weatherTimer->start(600000);

    connect(m_networkManager, &QNetworkAccessManager::finished, this, &SystemManager::handleNetworkReply);

    connect(&m_bluetoothReader, &BluetoothReader::devicesChanged, this, [this]() {
        emit bluetoothChanged();
    });

    connect(&m_volumeReader, &VolumeReader::dataUpdated, this, [this]() {
        emit volumeChanged();
    });

    QTimer *appsTimer = new QTimer(this);
    connect(appsTimer, &QTimer::timeout, this, [this]() {
        m_volumeReader.updateVolumeStatus();
    });
    appsTimer->start(8000);
    
    m_volumeReader.startEventListener([]() {
    });

    m_bluetoothReader.updateDevices();
    m_volumeReader.updateVolumeStatus();
    fetchWeather();
}

int SystemManager::ramUsage() const { return m_ramUsage; }
int SystemManager::cpuUsage() const { return m_cpuUsage; }
double SystemManager::diskUsage() const { return m_diskUsage; }
int SystemManager::cpuTemp() const { return m_cpuTemp; }
QString SystemManager::weather() const { return m_weather; }

void SystemManager::update() {
    m_cpuUsage = m_cpuReader.readUsagePercent();
    emit cpuUsageChanged();

    m_ramUsage = m_ramReader.readUsagePercent();
    emit ramUsageChanged();

    m_diskUsage = m_diskReader.readUsagePercent("/home");
    emit diskUsageChanged();

    m_cpuTemp = m_tempReader.readCpuTemperature();
    emit cpuTempChanged();

    m_networkReader.updateNetworkStatus();
    emit networkChanged();

    m_bluetoothReader.updateDevices();
    emit bluetoothChanged();

    m_volumeReader.updateVolumeStatus();
    emit volumeChanged();

    updateBattery();
    updateBrightness();
    updatePowerProfile();

}
void jozet::SystemManager::updateBattery() {
    QFile capacityFile("/sys/class/power_supply/BAT1/capacity");
    if (capacityFile.open(QIODevice::ReadOnly)) {
        int capacity = capacityFile.readAll().trimmed().toInt();
        if (m_batteryCapacity != capacity) {
            m_batteryCapacity = capacity;
            emit batteryCapacityChanged();
        }
    }

    QFile statusFile("/sys/class/power_supply/BAT1/status");
    if (statusFile.open(QIODevice::ReadOnly)) {
        QString status = statusFile.readAll().trimmed();
        if (m_batteryStatus != status) {
            m_batteryStatus = status;
            emit batteryStatusChanged();
        }
    }
}
void jozet::SystemManager::setPowerProfile(const QString& profile) {
    if (profile == "power-saver" || profile == "balanced" || profile == "performance") {
        QProcess::startDetached("powerprofilesctl", QStringList() << "set" << profile);
        m_powerProfile = profile;
        emit powerProfileChanged();
    }
}
void jozet::SystemManager::setBrightness(int percentage) {
    percentage = std::clamp(percentage, 5, 100); 
    
    QString command = QString("brightnessctl set %1%").arg(percentage);
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << command);
    
    m_brightness = percentage;
    emit brightnessChanged();
}
void jozet::SystemManager::updatePowerProfile() {
    QProcess process;
    process.start("powerprofilesctl", QStringList() << "get");
    process.waitForFinished(500);

    QString current = process.readAllStandardOutput().trimmed();
    if (!current.isEmpty() && m_powerProfile != current) {
        m_powerProfile = current;
        emit powerProfileChanged();
    }
}
void SystemManager::updateBrightness() {
    runCommandAsync("brightnessctl", {"-m"}, [this](const QString &output) {
        if (output.isEmpty()) return;
        QStringList parts = output.split(',');
        if (parts.size() >= 4) {
            int brightness = parts[3].chopped(1).toInt();
            if (m_brightness != brightness) {
                m_brightness = brightness;
                emit brightnessChanged();
            }
        }
    });
}

QVariantMap SystemManager::playbackDeviceInfo() const {
    QVariantMap info = m_volumeReader.playbackDeviceInfo();
    if (info.isEmpty()) {
        return { {"volume", 0}, {"isMuted", false}, {"name", "Esperando Audio..."} };
    }
    return info;
}

QVariantMap SystemManager::inputDeviceInfo() const {
    QVariantMap info = m_volumeReader.inputDeviceInfo();
    if (info.isEmpty()) {
        return { {"volume", 0}, {"isMuted", false}, {"name", "Sin Micrófono"} };
    }
    return info;
}
void SystemManager::fetchWeather() {
    QUrl url("https://wttr.in/?format=%t");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "curl/7.64.1");
    m_networkManager->get(request);
}

void SystemManager::handleNetworkReply(QNetworkReply *reply) {
    if (!reply) return;
    if (reply->error() == QNetworkReply::NoError) {
        m_weather = reply->readAll().trimmed();
        emit weatherChanged();
    } else {
        qDebug() << "Error en red:" << reply->errorString();
    }
    reply->deleteLater();
}

void SystemManager::scanBluetooth(bool start) {
    m_bluetoothReader.scan(start);
    if (start) {
        m_bluetoothReader.updateDevices();
    }
}

void SystemManager::runCommandAsync(const QString &program, const QStringList &args,
                                     std::function<void(const QString &)> callback) {
    QProcess *process = new QProcess(this);
    connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [process, callback](int exitCode, QProcess::ExitStatus status) {
        if (status == QProcess::NormalExit && exitCode == 0) {
            callback(QString::fromUtf8(process->readAllStandardOutput()).trimmed());
        }
        process->deleteLater();
    });
    process->start(program, args);
}

void SystemManager::connectBluetooth(const QString &address) {
    m_bluetoothReader.connectDevice(address);
}

void SystemManager::disconnectBluetooth(const QString &address) {
    m_bluetoothReader.disconnectDevice(address);
}

void SystemManager::forgetBluetooth(const QString &address) {
    m_bluetoothReader.forgetDevice(address);
}

QString jozet::SystemManager::powerProfile() const {
    return m_powerProfile;
}

#include <QThread>

void SystemManager::refreshDiskStats() {
    QThread *workerThread = QThread::create([this]() {
        
        QVariantList tempFolders = m_diskReader.getHomeFoldersUsage();
        QVariantList tempPartitions = m_diskReader.getPartitionsStatus();
        QVariantMap tempIO = m_diskReader.getDiskHealthAndIO();
        QVariantMap tempMaint = m_diskReader.getMaintenanceInfo();

        QMetaObject::invokeMethod(this, [this, tempFolders, tempPartitions, tempIO, tempMaint]() {
            m_homeFoldersUsage = tempFolders;
            m_partitionsStatus = tempPartitions;
            m_diskHealthAndIO = tempIO;
            m_maintenanceInfo = tempMaint;
            
            emit diskUsageChanged();
        }, Qt::QueuedConnection);
    });

    connect(workerThread, &QThread::finished, workerThread, &QObject::deleteLater);
    
    workerThread->start();
}

void SystemManager::cleanCache() {
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << "rm -rf ~/.cache/* 2>/dev/null");    
    refreshDiskStats();
}

void SystemManager::cleanTrash() {
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << "rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/*");
    refreshDiskStats();
}

}
