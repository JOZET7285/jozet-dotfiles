#pragma once

#include <QObject>
#include <QtQml/qqml.h>

#include <QNetworkAccessManager>
#include <QString>
#include <QNetworkReply>
#include <QVariantMap>
#include <pwd.h>
#include <unistd.h>

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
#include "Readers/UdisksReader.h"
#include "Readers/SettingsReader.h"
#include "Readers/HardwareReader.h"
#include "Readers/MatugenReader.h"
#include "Readers/HyprlandWriter.h"
#include "Readers/NotifyReader.h"
#include "Readers/CursorReader.h"
#include "Readers/MediaReader.h"

namespace jozet {

class SystemManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON 
    QML_ELEMENT
    QML_ADDED_IN_MINOR_VERSION(0)

    Q_PROPERTY(bool locked READ locked WRITE setLocked NOTIFY lockedChanged)
    Q_PROPERTY(QString currentUsername READ currentUsername CONSTANT)
    QString currentUsername() const;

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
    Q_PROPERTY(QVariantList allPlaybackDevices READ allPlaybackDevices NOTIFY volumeChanged)
    Q_PROPERTY(QVariantList allInputDevices READ allInputDevices NOTIFY volumeChanged)
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

    // USB -------------------------------------------------------
    Q_PROPERTY(QVariantList usbDevices READ usbDevices NOTIFY usbDevicesChanged)

    // SETTINGS --------------------------------------------------
    Q_PROPERTY(QVariantMap riceSettings READ riceSettings NOTIFY riceSettingsChanged)
    Q_PROPERTY(QVariantMap matugenColors READ matugenColors NOTIFY matugenColorsChanged)
    Q_PROPERTY(bool doNotDisturb READ doNotDisturb WRITE setDoNotDisturb NOTIFY doNotDisturbChanged)
    Q_PROPERTY(QVariantList availableCursors READ availableCursors NOTIFY availableCursorsChanged)

    // SYSTEM INFO -----------------------------------------------
    Q_PROPERTY(QVariantMap systemInfo READ systemInfo NOTIFY systemInfoChanged)
    Q_PROPERTY(QVariantMap latestNotification READ latestNotification NOTIFY notificationReceived)

    // MEDIA -------------------------------------------------------
    Q_PROPERTY(QString mediaTitle READ mediaTitle NOTIFY mediaChanged)
    Q_PROPERTY(QString mediaArtist READ mediaArtist NOTIFY mediaChanged)
    Q_PROPERTY(QString mediaAlbum READ mediaAlbum NOTIFY mediaChanged)
    Q_PROPERTY(QString mediaArtUrl READ mediaArtUrl NOTIFY mediaChanged)
    Q_PROPERTY(bool mediaPlaying READ mediaPlaying NOTIFY mediaChanged)
    Q_PROPERTY(bool mediaHasPlayer READ mediaHasPlayer NOTIFY mediaChanged)
    Q_PROPERTY(qint64 mediaPositionUs READ mediaPositionUs NOTIFY mediaPositionChanged)
    Q_PROPERTY(qint64 mediaLengthUs READ mediaLengthUs NOTIFY mediaChanged)

public:
    explicit SystemManager(QObject *parent = nullptr);
    
    Q_INVOKABLE bool authenticateUser(const QString &username, const QString &password);
    bool locked() const { return m_locked; }
    void setLocked(bool locked);
    Q_INVOKABLE void lockSession();
    Q_INVOKABLE void unlockSession();
    
    Q_INVOKABLE QString getWallpaperCachePath(const QString &monitorName);
    
    QVariantMap matugenColors() const { return m_matugenReader.colors(); }
    
    QVariantList availableCursors() const { return m_cursorReader.availableCursors(); }
    Q_INVOKABLE void refreshCursors() { m_cursorReader.refreshCursors(); }

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
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password, const bool &saved);

    // BLUETOOTH -----------------------------------------------
    QVariantList availableBluetoothDevices() const { return m_bluetoothReader.availableDevices(); }

    Q_INVOKABLE void scanBluetooth(bool start);
    Q_INVOKABLE void connectBluetooth(const QString &address);
    Q_INVOKABLE void disconnectBluetooth(const QString &address);
    Q_INVOKABLE void forgetBluetooth(const QString &address);

    // AUDIO -----------------------------------------------
    QVariantMap playbackDeviceInfo() const;
    QVariantMap inputDeviceInfo() const;
    QVariantList allPlaybackDevices() const { return m_volumeReader.allPlaybackDevices(); }
    QVariantList allInputDevices() const { return m_volumeReader.allInputDevices(); }
    
    QVariantList playingApplications() const { return m_volumeReader.playingApplications(); }
    bool isVolumeReady() const { return !m_volumeReader.playbackDeviceInfo().isEmpty(); }

    Q_INVOKABLE void setPlaybackVolume(int volume);
    Q_INVOKABLE void setInputVolume(int volume);
    Q_INVOKABLE void setPlaybackMuted(bool muted);
    Q_INVOKABLE void setInputMuted(bool muted);
    Q_INVOKABLE void setDeviceVolume(uint32_t index, int volume);
    Q_INVOKABLE void setDeviceMuted(uint32_t index, bool muted);
    Q_INVOKABLE void setSourceDeviceVolume(uint32_t index, int volume);
    Q_INVOKABLE void setSourceDeviceMuted(uint32_t index, bool muted);
    Q_INVOKABLE void setApplicationVolume(uint32_t pid, int volume);
    Q_INVOKABLE void setDefaultPlaybackDevice(uint32_t index);
    Q_INVOKABLE void setDefaultInputDevice(uint32_t index);

    // POWER -----------------------------------------------
    int batteryCapacity() const { return m_batteryCapacity; }
    QString batteryStatus() const { return m_batteryStatus; }
    int brightness() const { return m_brightness; }
    QString powerProfile() const;

    Q_INVOKABLE void setBrightness(int percentage);
    Q_INVOKABLE void setBrightnessPersist(int percentage);
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

    // USB -------------------------------------------------------
    QVariantList usbDevices() const { return m_udisksReader.devices(); }

    Q_INVOKABLE void refreshUsbDevices();
    Q_INVOKABLE void mountUsbDevice(const QString &path);
    Q_INVOKABLE void unmountUsbDevice(const QString &path);

    // SETTINGS --------------------------------------------------
    QVariantMap riceSettings() const { return m_settingsReader.settings(); }

    Q_INVOKABLE QVariant getSetting(const QString &key) const;
    Q_INVOKABLE void setSetting(const QString &key, const QVariant &value);
    Q_INVOKABLE void resetSettings();

    // SYSTEM INFO -----------------------------------------------
    QVariantMap systemInfo() const { return m_hardwareReader.systemInfo(); }
    Q_INVOKABLE void refreshSystemInfo();
    QVariantMap latestNotification() const { return m_latestNotification; }
    bool doNotDisturb() const;
    void setDoNotDisturb(bool dnd);
    Q_INVOKABLE void closeNotification(uint id);

    // MEDIA -------------------------------------------------------
    QString mediaTitle() const { return m_mediaReader.title(); }
    QString mediaArtist() const { return m_mediaReader.artist(); }
    QString mediaAlbum() const { return m_mediaReader.album(); }
    QString mediaArtUrl() const { return m_mediaReader.artUrl(); }
    bool mediaPlaying() const { return m_mediaReader.isPlaying(); }
    bool mediaHasPlayer() const { return m_mediaReader.hasPlayer(); }
    qint64 mediaPositionUs() const { return m_mediaReader.positionUs(); }
    qint64 mediaLengthUs() const { return m_mediaReader.lengthMicroseconds(); }

    Q_INVOKABLE void mediaPlayPause() { m_mediaReader.playPause(); }
    Q_INVOKABLE void mediaNext() { m_mediaReader.next(); }
    Q_INVOKABLE void mediaPrevious() { m_mediaReader.previous(); }

    // MONITORS --------------------------------------------------
    Q_INVOKABLE QString getMonitorsJson();
    Q_INVOKABLE void applyMonitorConfig(const QString &name, const QString &resolution, const QString &rate, int transform, double scale);
    Q_INVOKABLE void setMonitorEnabled(const QString &name, bool enabled);
    Q_INVOKABLE void setMonitorLayout(const QString &primary, const QString &secondary, const QString &mode);
    Q_INVOKABLE void setMonitorVrr(const QString &name, bool enabled);
    Q_INVOKABLE void refreshMonitors();

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
    void lockedChanged();
    void usbDevicesChanged();
    void riceSettingsChanged();
    void systemInfoChanged();
    void matugenColorsChanged();
    void notificationReceived();
    void notificationClosed(uint id, uint reason);
    void doNotDisturbChanged();
    void availableCursorsChanged();
    void mediaChanged();
    void mediaPositionChanged();

private slots:
    void update();
    void fetchWeather();
    void refreshTopProcesses();
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
    UdisksReader m_udisksReader;
    SettingsReader m_settingsReader;
    HardwareReader m_hardwareReader;
    QVariantList m_workspaces;
    MatugenReader m_matugenReader;
    HyprlandWriter *m_hyprlandWriter = nullptr;
    bool m_locked = false;
    CursorReader m_cursorReader;
    MediaReader m_mediaReader;
    QFileSystemWatcher *m_brightnessWatcher = nullptr;
    QString m_backlightPath;

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

    // SETTINGS ---------------------
    void applyActiveProfileBrightness();    
    void persistBrightnessToActiveProfile(int percentage);
    NotifyReader m_notifyReader;
    QVariantMap m_latestNotification;
    
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
