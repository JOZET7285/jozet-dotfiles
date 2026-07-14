#pragma once
#include <QObject>
#include <QtQml/qqml.h>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "Readers/CpuReader.h"
#include "Readers/RamReader.h"
#include "Readers/DiskReader.h"
#include "Readers/TempReader.h"
#include "Readers/NetworkReader.h"
#include "Readers/BluetoothReader.h"
#include "Readers/VolumeReader.h"

namespace jozet {
    class SystemManager : public QObject
    {
        Q_OBJECT
        QML_ELEMENT
        QML_ADDED_IN_MINOR_VERSION(0)

        Q_PROPERTY(int ramUsage READ ramUsage NOTIFY ramUsageChanged)
        Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)

        Q_PROPERTY(double diskUsage READ diskUsage NOTIFY diskUsageChanged)
        Q_PROPERTY(QVariantList homeFoldersUsage READ homeFoldersUsage NOTIFY diskUsageChanged)
        Q_PROPERTY(QVariantList partitionsStatus READ partitionsStatus NOTIFY diskUsageChanged)
        Q_PROPERTY(QVariantMap diskHealthAndIO READ diskHealthAndIO NOTIFY diskUsageChanged)
        Q_PROPERTY(QVariantMap maintenanceInfo READ maintenanceInfo NOTIFY diskUsageChanged)

        Q_PROPERTY(int cpuTemp READ cpuTemp NOTIFY cpuTempChanged)

        Q_PROPERTY(QString weather READ weather NOTIFY weatherChanged)

        Q_PROPERTY(QVariantList availableNetworks READ availableNetworks NOTIFY networkChanged)
        Q_PROPERTY(QVariantMap ethernetInfo READ ethernetInfo NOTIFY networkChanged)
        Q_PROPERTY(QVariantMap wifiInfo READ wifiInfo NOTIFY networkChanged)

        Q_PROPERTY(QVariantList availableBluetoothDevices READ availableBluetoothDevices NOTIFY bluetoothChanged)

        Q_PROPERTY(QVariantMap playbackDeviceInfo READ playbackDeviceInfo NOTIFY volumeChanged)
        Q_PROPERTY(QVariantMap inputDeviceInfo READ inputDeviceInfo NOTIFY volumeChanged)
        Q_PROPERTY(QVariantList playingApplications READ playingApplications NOTIFY volumeChanged)
        Q_PROPERTY(bool isVolumeReady READ isVolumeReady NOTIFY volumeChanged)
        
        Q_PROPERTY(int batteryCapacity READ batteryCapacity NOTIFY batteryCapacityChanged)
        Q_PROPERTY(QString batteryStatus READ batteryStatus NOTIFY batteryStatusChanged)

        Q_PROPERTY(int brightness READ brightness NOTIFY brightnessChanged)

        Q_PROPERTY(QString powerProfile READ powerProfile NOTIFY powerProfileChanged)

        
        int batteryCapacity() const { return m_batteryCapacity; }
        QString batteryStatus() const { return m_batteryStatus; }
        int brightness() const { return m_brightness; }
        
    public:
        explicit SystemManager(QObject *parent = nullptr);

        int ramUsage() const;
        int cpuUsage() const;

        double diskUsage() const;
        QVariantList homeFoldersUsage() const { return m_homeFoldersUsage; }
        QVariantList partitionsStatus() const { return m_partitionsStatus; }
        QVariantMap diskHealthAndIO() const { return m_diskHealthAndIO; }
        QVariantMap maintenanceInfo() const { return m_maintenanceInfo; }
        Q_INVOKABLE void cleanCache();
        Q_INVOKABLE void cleanTrash();

        int cpuTemp() const;

        QString weather() const;
        
        QVariantMap ethernetInfo() const { return m_networkReader.ethernetInfo(); }
        QVariantMap wifiInfo() const { return m_networkReader.wifiInfo(); }
        
        QVariantList availableBluetoothDevices() const { return m_bluetoothReader.availableDevices(); }
        
        Q_INVOKABLE QVariantMap playbackDeviceInfo() const;
        Q_INVOKABLE QVariantMap inputDeviceInfo() const;
        Q_INVOKABLE QVariantList playingApplications() const { return m_volumeReader.playingApplications(); }
        bool isVolumeReady() const { return !m_volumeReader.playbackDeviceInfo().isEmpty(); }
        QString powerProfile() const;
        Q_INVOKABLE void setPowerProfile(const QString& profile);

        Q_INVOKABLE QVariantList availableNetworks() const { return m_networkReader.availableNetworks(); }
        Q_INVOKABLE void scanNetworks() { m_networkReader.scanAvailableNetworks(); }
        Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password) {
            m_networkReader.connectToWifi(ssid, password);
        }
        Q_INVOKABLE void scanBluetooth(bool start);
        Q_INVOKABLE void connectBluetooth(const QString &address);
        Q_INVOKABLE void disconnectBluetooth(const QString &address);
        Q_INVOKABLE void forgetBluetooth(const QString &address);

        Q_INVOKABLE void setPlaybackVolume(int volume) { m_volumeReader.setPlaybackVolume(volume); }
        Q_INVOKABLE void setInputVolume(int volume) { m_volumeReader.setInputVolume(volume); }
        Q_INVOKABLE void setPlaybackMuted(bool muted) { m_volumeReader.setPlaybackMuted(muted); }
        Q_INVOKABLE void setInputMuted(bool muted) { m_volumeReader.setInputMuted(muted); }
        Q_INVOKABLE void setApplicationVolume(uint32_t pid, int volume) { m_volumeReader.setApplicationVolume(pid, volume); }
        Q_INVOKABLE void setDefaultPlaybackDevice(uint32_t index) { m_volumeReader.setDefaultPlaybackDevice(index); }
        Q_INVOKABLE void setDefaultInputDevice(uint32_t index) { m_volumeReader.setDefaultInputDevice(index); }
        Q_INVOKABLE void setBrightness(int percentage);
        
        Q_INVOKABLE void refreshDiskStats();

        Q_INVOKABLE void powerOff();
        Q_INVOKABLE void reboot();
        Q_INVOKABLE void suspend();

    signals:
        void ramUsageChanged();
        void cpuUsageChanged();
        void diskUsageChanged();
        void cpuTempChanged();
        void weatherChanged();
        void networkChanged();
        void bluetoothChanged();
        void volumeChanged();

        void batteryCapacityChanged();
        void batteryStatusChanged();
        void brightnessChanged();
        void powerProfileChanged();

    private slots:
        void update();
        void fetchWeather();
        void handleNetworkReply(QNetworkReply *reply);

    private:
        int m_ramUsage = 0;
        int m_cpuUsage = 0;
        double m_diskUsage = 0.0;
        int m_cpuTemp = 0;
        QString m_weather;

        CpuReader m_cpuReader;
        RamReader m_ramReader;
    
        DiskReader m_diskReader;
        QVariantList m_homeFoldersUsage;
        QVariantList m_partitionsStatus;
        QVariantMap m_diskHealthAndIO;
        QVariantMap m_maintenanceInfo;

        TempReader m_tempReader;
        NetworkReader m_networkReader;
        BluetoothReader m_bluetoothReader;
        VolumeReader m_volumeReader;
        
        QString m_powerProfile = "balanced";
        
        void updatePowerProfile();
        int m_batteryCapacity = 0;

        QString m_batteryStatus = "Unknown";
        int m_brightness = 0;
        
        void updateBattery();
        void updateBrightness();

        void runCommandAsync(const QString &program, const QStringList &args,
                      std::function<void(const QString &)> callback);

        QNetworkAccessManager *m_networkManager = nullptr;
    };
}