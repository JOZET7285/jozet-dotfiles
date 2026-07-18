#pragma once

#include <QObject>
#include <QtQml/qqml.h>

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantMap>

#include "Readers/BluetoothReader.h"
#include "Readers/CpuReader.h"
#include "Readers/DiskReader.h"
#include "Readers/NetworkReader.h"
#include "Readers/ProcessReader.h"
#include "Readers/RamReader.h"
#include "Readers/TempReader.h"
#include "Readers/VolumeReader.h"
#include "Readers/AgendaReader.h"
#include "Readers/StatsReader.h"
#include "Readers/EventsReader.h"
#include "Readers/HyprlandReader.h"
#include "Readers/PamAuthenticator.h"

namespace jozet {

class SystemManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ADDED_IN_MINOR_VERSION(0)

    // RAM -----------------------------------------------
    Q_PROPERTY(QVariantMap ramInfo READ ramInfo NOTIFY ramInfoChanged)
    Q_PROPERTY(QVariantList topRamProcesses READ topRamProcesses NOTIFY topRamProcessesChanged)

    // CPU -------------------------------------------------------------------------------------
    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
    Q_PROPERTY(QVariantList topCpuProcesses READ topCpuProcesses NOTIFY topCpuProcessesChanged)
    Q_PROPERTY(int cpuFrequency READ cpuFrequency NOTIFY cpuFrequencyChanged)

    // TEMP ------------------------------------------------------------------------------------
    Q_PROPERTY(int maxTemp READ maxTemp NOTIFY maxTempChanged)
    Q_PROPERTY(QVariantList sensorTemperatures READ sensorTemperatures NOTIFY sensorTemperaturesChanged)

    // DISK ---------------------------------------------------------------------------------------------
    Q_PROPERTY(double diskUsage READ diskUsage NOTIFY diskUsageChanged)
    Q_PROPERTY(QVariantList homeFoldersUsage READ homeFoldersUsage NOTIFY diskUsageChanged)
    Q_PROPERTY(QVariantList partitionsStatus READ partitionsStatus NOTIFY diskUsageChanged)
    Q_PROPERTY(QVariantMap diskHealthAndIO READ diskHealthAndIO NOTIFY diskUsageChanged)
    Q_PROPERTY(QVariantMap maintenanceInfo READ maintenanceInfo NOTIFY diskUsageChanged)

    // NETWORK ----------------------------------------------------------------------------
    Q_PROPERTY(QVariantList availableNetworks READ availableNetworks NOTIFY networkChanged)
    Q_PROPERTY(QVariantMap ethernetInfo READ ethernetInfo NOTIFY networkChanged)
    Q_PROPERTY(QVariantMap wifiInfo READ wifiInfo NOTIFY networkChanged)

    // BLUETOOTH ----------------------------------------------------------------------------
    Q_PROPERTY(QVariantList availableBluetoothDevices READ availableBluetoothDevices NOTIFY bluetoothChanged)
 
    // AUDIO -------------------------------------------------------------------------------------------------
    Q_PROPERTY(QVariantMap playbackDeviceInfo READ playbackDeviceInfo NOTIFY volumeChanged)
    Q_PROPERTY(QVariantMap inputDeviceInfo READ inputDeviceInfo NOTIFY volumeChanged)
    Q_PROPERTY(QVariantList playingApplications READ playingApplications NOTIFY volumeChanged)
    Q_PROPERTY(bool isVolumeReady READ isVolumeReady NOTIFY volumeChanged)

    // POWER ---------------------------------------------------------------------------------
    Q_PROPERTY(int batteryCapacity READ batteryCapacity NOTIFY batteryCapacityChanged)
    Q_PROPERTY(QString batteryStatus READ batteryStatus NOTIFY batteryStatusChanged)
    Q_PROPERTY(int brightness READ brightness NOTIFY brightnessChanged)
    Q_PROPERTY(QString powerProfile READ powerProfile NOTIFY powerProfileChanged)

    // WEATHER -----------------------------------------------------------------------
    Q_PROPERTY(QString weather READ weather NOTIFY weatherChanged)

    // TODAY -----------------------------------------------------
    Q_PROPERTY(QVariantMap userStats READ userStats NOTIFY todayDataChanged)
    Q_PROPERTY(QVariantList events READ events NOTIFY todayDataChanged)
    Q_PROPERTY(QVariantList agenda READ agenda NOTIFY todayDataChanged)

    // WORKSPACES ------------------------------------------------
    Q_PROPERTY(QVariantList workspaces READ workspaces NOTIFY workspacesChanged)

public:
    explicit SystemManager(QObject *parent = nullptr);
    Q_INVOKABLE bool authenticateUser(const QString &username, const QString &password);

    // RAM -----------------------------------------------
    QVariantMap ramInfo() const;
    QVariantList topRamProcesses() const;
    Q_INVOKABLE void updateRam();

    // CPU -----------------------------------------------
    int cpuUsage() const;
    QVariantList topCpuProcesses() const;
    int cpuFrequency() const;

    // TEMP ----------------------------------------------
    int maxTemp() const { return m_maxTemp; }
    QVariantList sensorTemperatures() const { return m_sensorTemperatures; }

    // DISK -----------------------------------------------
    double diskUsage() const;

    QVariantList homeFoldersUsage() const;
    QVariantList partitionsStatus() const { return m_partitionsStatus; }
    QVariantMap diskHealthAndIO() const { return m_diskHealthAndIO; }
    QVariantMap maintenanceInfo() const;

    Q_INVOKABLE void refreshDiskStats();
    Q_INVOKABLE void cleanCache();
    Q_INVOKABLE void cleanTrash();

    // NETWORK -----------------------------------------------
    QVariantMap ethernetInfo() const { return m_networkReader.ethernetInfo(); }
    QVariantMap wifiInfo() const { return m_networkReader.wifiInfo(); }
    QVariantList availableNetworks() const { return m_networkReader.availableNetworks(); }

    Q_INVOKABLE void scanNetworks();
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password);

    // BLUETOOTH -----------------------------------------------
    QVariantList availableBluetoothDevices() const { return m_bluetoothReader.availableDevices(); }

    Q_INVOKABLE void scanBluetooth(bool start);
    Q_INVOKABLE void connectBluetooth(const QString &address);
    Q_INVOKABLE void disconnectBluetooth(const QString &address);
    Q_INVOKABLE void forgetBluetooth(const QString &address);

    // AUDIO -----------------------------------------------
    QVariantMap playbackDeviceInfo() const;
    QVariantMap inputDeviceInfo() const;
    
    QVariantList playingApplications() const { return m_volumeReader.playingApplications(); }
    bool isVolumeReady() const { return !m_volumeReader.playbackDeviceInfo().isEmpty(); }

    Q_INVOKABLE void setPlaybackVolume(int volume);
    Q_INVOKABLE void setInputVolume(int volume);
    Q_INVOKABLE void setPlaybackMuted(bool muted);
    Q_INVOKABLE void setInputMuted(bool muted);
    Q_INVOKABLE void setApplicationVolume(uint32_t pid, int volume);
    Q_INVOKABLE void setDefaultPlaybackDevice(uint32_t index);
    Q_INVOKABLE void setDefaultInputDevice(uint32_t index);

    // POWER -----------------------------------------------
    int batteryCapacity() const { return m_batteryCapacity; }
    QString batteryStatus() const { return m_batteryStatus; }
    int brightness() const { return m_brightness; }
    QString powerProfile() const;

    Q_INVOKABLE void setBrightness(int percentage);
    Q_INVOKABLE void setPowerProfile(const QString &profile);
    Q_INVOKABLE void suspend();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void powerOff();

    // WEATHER -----------------------------------------------
    QString weather() const;

    // TODAY -----------------------
    QVariantList agenda() const { return m_agenda; }
    QVariantList events() const { return m_events; }
    QVariantMap userStats() const { return m_userStats; }
    
    Q_INVOKABLE void refreshTodayData();
    Q_INVOKABLE void toggleAgendaTask(int index);
    Q_INVOKABLE void addEvent(const QString &date, const QString &title);
    Q_INVOKABLE void addAgendaTask(const QString &task);

    // WORKSPACES ------------------------------------------------
    QVariantList workspaces() const { return m_workspaces; }
    
    Q_INVOKABLE void refreshWorkspaces();

signals:
    void ramInfoChanged();
    void topRamProcessesChanged();
    void cpuUsageChanged();
    void maxTempChanged();
    void sensorTemperaturesChanged();
    void topCpuProcessesChanged();
    void cpuFrequencyChanged();
    void diskUsageChanged();
    void homeFoldersUsageChanged();
    void maintenanceInfoChanged();
    void networkChanged();
    void bluetoothChanged();
    void volumeChanged();
    void batteryCapacityChanged();
    void batteryStatusChanged();
    void brightnessChanged();
    void powerProfileChanged();
    void weatherChanged();
    void todayDataChanged();
    void workspacesChanged();

private slots:
    void update();
    void fetchWeather();
    void handleNetworkReply(QNetworkReply *reply);

private:
    // READERS -----------------------------------------------
    CpuReader m_cpuReader;
    RamReader m_ramReader;
    ProcessReader m_processReader;
    DiskReader m_diskReader;
    TempReader m_tempReader;
    NetworkReader m_networkReader;
    BluetoothReader m_bluetoothReader;
    VolumeReader m_volumeReader;
    HyprlandReader m_hyprlandReader;
    QVariantList m_workspaces;

    // RAM ------------------------------------------------
    QVariantMap m_ramInfo;
    QVariantList m_topRamProcesses;

    // CPU -----------------------------------------------
    int m_cpuUsage = 0;
    QVariantList m_topCpuProcesses;
    int m_cpuFrequency = 0;

    // TEMP ---------------------------------------------
    int m_maxTemp = 0;
    QVariantList m_sensorTemperatures;

    // DISK -----------------------------------------------
    double m_diskUsage = 0.0;
    QVariantList m_homeFoldersUsage;
    QVariantList m_partitionsStatus;
    QVariantMap m_diskHealthAndIO;
    QVariantMap m_maintenanceInfo;

    // POWER -----------------------------------------------
    QString m_powerProfile = "balanced";
    int m_batteryCapacity = 0;
    QString m_batteryStatus = "Unknown";
    int m_brightness = 0;

    // WEATHER ------------------------------------
    QString m_weather;
    QNetworkAccessManager *m_networkManager = nullptr;

    // TODAY ------------------------------------------
    AgendaReader m_agendaReader;
    StatsReader m_statsReader;
    QVariantList m_agenda;
    QVariantMap m_userStats;
    EventsReader m_eventsReader;
    QVariantList m_events;

    // HELPERS --------------------------------------------
    void updateCpu();
    void updateBattery();
    void updateBrightness();
    void updatePowerProfile();
    PamAuthenticator m_pamAuth;

    void runCommandAsync(
        const QString &program,
        const QStringList &args,
        std::function<void(const QString &)> callback);
};

}