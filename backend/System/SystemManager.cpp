#include "System/SystemManager.h"
#include <QTimer>
#include <QUrl>
#include <QNetworkRequest>
#include <QDebug>

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
    if (reply && reply->error() == QNetworkReply::NoError) {
        m_weather = reply->readAll().trimmed();
        emit weatherChanged();
    } else {
        qDebug() << "Error en red:" << (reply ? reply->errorString() : "Desconocido");
    }
    reply->deleteLater();
}

void SystemManager::scanBluetooth(bool start) {
    m_bluetoothReader.scan(start);
    if (start) {
        m_bluetoothReader.updateDevices();
    }
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

}