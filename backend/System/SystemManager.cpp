#include "System/SystemManager.h"

#include <QDebug>
#include <QNetworkRequest>
#include <QProcess>
#include <QThread>
#include <QTimer>
#include <QUrl>
#include <QDir>
#include <QFileInfo>
#include <QFileInfoList>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

#include <algorithm>

namespace jozet {

// Constructor
// ------------------------------------------------------------

SystemManager::SystemManager(QObject *parent) : QObject(parent)
{
    m_networkManager = new QNetworkAccessManager(this);

    auto *timer = new QTimer(this);
    timer->setInterval(1400);
    connect(timer, &QTimer::timeout, this, &SystemManager::update);
    timer->start();

    auto *weatherTimer = new QTimer(this);
    connect(weatherTimer, &QTimer::timeout, this, &SystemManager::fetchWeather);
    weatherTimer->start(900000);

    auto *appsTimer = new QTimer(this);
    connect(appsTimer, &QTimer::timeout, this, [this]() {
        m_volumeReader.updateVolumeStatus();
    });
    appsTimer->start(8000);

    connect(m_networkManager, &QNetworkAccessManager::finished, this, &SystemManager::handleNetworkReply);
    connect(&m_bluetoothReader, &BluetoothReader::devicesChanged, this, [this]() { emit bluetoothChanged(); });
    connect(&m_volumeReader, &VolumeReader::dataUpdated, this, [this]() { emit volumeChanged(); });
    connect(&m_hyprlandReader, &HyprlandReader::workspacesShouldRefresh, this, [this]() {
        refreshWorkspaces();
    });
    connect(&m_udisksReader, &UdisksReader::devicesChanged, this, [this]() {
        emit usbDevicesChanged();
    });
    connect(&m_settingsReader, &SettingsReader::settingsChanged, this, [this]() {
        emit riceSettingsChanged();
        applyActiveProfileBrightness();
    });
    connect(&m_fastfetchReader, &FastfetchReader::systemInfoChanged, this, [this]() {
        emit systemInfoChanged();
    });

    connect(&m_matugenReader, &MatugenReader::colorsChanged, this, [this]() {
        m_hyprlandWriter->applyAll();
        emit matugenColorsChanged();
    });

    connect(&m_notifyReader, &NotifyReader::notificationReceived, this, [this](const QVariantMap &notif) {
        m_latestNotification = notif;
        emit notificationReceived();
    });

    connect(&m_notifyReader, &NotifyReader::notificationClosed, this, [this](uint id, uint reason) {
        emit notificationClosed(id, reason);
    });

    m_hyprlandWriter = new HyprlandWriter(&m_settingsReader, &m_matugenReader, this);

    m_volumeReader.startEventListener([](){});
    m_bluetoothReader.updateDevices();
    m_volumeReader.updateVolumeStatus();

    fetchWeather();
    refreshTodayData();
    refreshWorkspaces();
}

// RAM
// ------------------------------------------------------------

QVariantMap SystemManager::ramInfo() const
{
    return m_ramInfo;
}

QVariantList SystemManager::topRamProcesses() const
{
    return m_topRamProcesses;
}

void SystemManager::updateRam()
{
    RamData data = m_ramReader.readData();

    QVariantMap newRamInfo;
    newRamInfo["totalMB"] = QVariant::fromValue(data.totalMB);
    newRamInfo["usedMB"] = QVariant::fromValue(data.usedMB);
    
    newRamInfo["usagePercent"] = QVariant::fromValue(data.usagePercent);

    newRamInfo["swapTotalMB"] = QVariant::fromValue(data.swapTotalMB);
    newRamInfo["swapUsedMB"] = QVariant::fromValue(data.swapUsedMB);
    
    newRamInfo["swapUsagePercent"] = QVariant::fromValue(data.swapUsagePercent);

    if (m_ramInfo != newRamInfo) {
        m_ramInfo = newRamInfo;
        emit ramInfoChanged();
    }

    QVariantList newProcessList = m_processReader.readTopRamProcesses(5);
    if (m_topRamProcesses != newProcessList) {
        m_topRamProcesses = newProcessList;
        emit topRamProcessesChanged();
    }
}

// CPU
// ------------------------------------------------------------

int SystemManager::cpuUsage() const
{
    return m_cpuUsage;
}

int SystemManager::cpuFrequency() const
{
    return m_cpuFrequency;
}

void SystemManager::updateCpu() {
    m_cpuUsage = m_cpuReader.readUsagePercent();
    emit cpuUsageChanged();

    int currentMaxTemp = m_tempReader.readMaxTemperature();
    if (m_maxTemp != currentMaxTemp) {
        m_maxTemp = currentMaxTemp;
        emit maxTempChanged();
    }

    QVariantList currentSensors = m_tempReader.readAllSensors();
    if (m_sensorTemperatures != currentSensors) {
        m_sensorTemperatures = currentSensors;
        emit sensorTemperaturesChanged();
    }

    int currentFreq = m_cpuReader.readCurrentFrequency();
    if (m_cpuFrequency != currentFreq) {
        m_cpuFrequency = currentFreq;
        emit cpuFrequencyChanged();
    }

    QVariantList newCpuProcessList = m_processReader.readTopCpuProcesses(5);
    if (m_topCpuProcesses != newCpuProcessList) {
        m_topCpuProcesses = newCpuProcessList;
        emit topCpuProcessesChanged();
    }
}

QVariantList SystemManager::topCpuProcesses() const
{
    return m_topCpuProcesses;
}

// Disk
// ------------------------------------------------------------

double SystemManager::diskUsage() const
{
    return m_diskUsage;
}

QVariantList SystemManager::homeFoldersUsage() const {
    return m_homeFoldersUsage;
}

QVariantMap SystemManager::maintenanceInfo() const {
    return m_maintenanceInfo;
}

void SystemManager::refreshDiskStats()
{
    auto *workerThread = QThread::create([this]() {

        QVariantList tempFolders = m_diskReader.getHomeFoldersUsage();
        QVariantList tempPartitions = m_diskReader.getPartitionsStatus();
        QVariantMap tempIO = m_diskReader.getDiskHealthAndIO();
        QVariantMap tempMaint = m_diskReader.getMaintenanceInfo();

        QMetaObject::invokeMethod(this,
            [this, tempFolders, tempPartitions, tempIO, tempMaint]() {

                m_homeFoldersUsage = tempFolders;
                m_partitionsStatus = tempPartitions;
                m_diskHealthAndIO = tempIO;
                m_maintenanceInfo = tempMaint;

                for (const QVariant &p : std::as_const(tempPartitions)) {
                    QVariantMap map = p.toMap();
                    if (map["path"].toString() == "/home") {
                        m_diskUsage = map["percent"].toDouble();
                        break;
                    }
                }

                emit diskUsageChanged();

            },
            Qt::QueuedConnection);
    });

    connect(workerThread, &QThread::finished, workerThread, &QObject::deleteLater);
    workerThread->start();
}

void SystemManager::cleanCache() {
    QDir cacheDir(QDir::homePath() + "/.cache");
    cacheDir.removeRecursively(); 
    cacheDir.mkpath(".");
    refreshDiskStats();
}
void SystemManager::cleanTrash()
{
    QProcess::startDetached(
        "/bin/sh",
        QStringList()
            << "-c"
            << "rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/*");

    refreshDiskStats();
}

// Network
// ------------------------------------------------------------

void SystemManager::fetchWeather()
{
    QNetworkRequest request(QUrl("https://wttr.in/?format=%t"));
    request.setHeader(QNetworkRequest::UserAgentHeader, "curl/7.64.1");

    m_networkManager->get(request);
}

void SystemManager::handleNetworkReply(QNetworkReply *reply)
{
    if (!reply)
        return;

    if (reply->error() == QNetworkReply::NoError) {
        m_weather = reply->readAll().trimmed();
        emit weatherChanged();
    }

    reply->deleteLater();
}

void SystemManager::scanNetworks()
{
    m_networkReader.scanAvailableNetworks([this](QVariantList) {
        emit networkChanged();
    });
}

void SystemManager::connectToNetwork(const QString &ssid, const QString &password, const bool &saved)
{
    m_networkReader.connectToWifi(ssid, password, saved);
}

// Bluetooth
// ------------------------------------------------------------

void SystemManager::scanBluetooth(bool start)
{
    m_bluetoothReader.scan(start);

    if (start)
        m_bluetoothReader.updateDevices();
}

void SystemManager::connectBluetooth(const QString &address)
{
    m_bluetoothReader.connectDevice(address);
}

void SystemManager::disconnectBluetooth(const QString &address)
{
    m_bluetoothReader.disconnectDevice(address);
}

void SystemManager::forgetBluetooth(const QString &address)
{
    m_bluetoothReader.forgetDevice(address);
}

// Audio
// ------------------------------------------------------------

QVariantMap SystemManager::playbackDeviceInfo() const
{
    QVariantMap info = m_volumeReader.playbackDeviceInfo();

    if (info.isEmpty()) {
        return {
            {"volume", 0},
            {"isMuted", false},
            {"name", "Esperando Audio..."}
        };
    }

    return info;
}

QVariantMap SystemManager::inputDeviceInfo() const
{
    QVariantMap info = m_volumeReader.inputDeviceInfo();

    if (info.isEmpty()) {
        return {
            {"volume", 0},
            {"isMuted", false},
            {"name", "Sin Micrófono"}
        };
    }

    return info;
}

void SystemManager::setPlaybackVolume(int volume)
{
    m_volumeReader.setPlaybackVolume(volume);
}

void SystemManager::setInputVolume(int volume)
{
    m_volumeReader.setInputVolume(volume);
}

void SystemManager::setPlaybackMuted(bool muted)
{
    m_volumeReader.setPlaybackMuted(muted);
}

void SystemManager::setInputMuted(bool muted)
{
    m_volumeReader.setInputMuted(muted);
}

void SystemManager::setDeviceVolume(uint32_t index, int volume)
{
    m_volumeReader.setDeviceVolume(index, volume);
}

void SystemManager::setDeviceMuted(uint32_t index, bool muted)
{
    m_volumeReader.setDeviceMuted(index, muted);
}

void SystemManager::setSourceDeviceVolume(uint32_t index, int volume)
{
    m_volumeReader.setSourceDeviceVolume(index, volume);
}

void SystemManager::setSourceDeviceMuted(uint32_t index, bool muted)
{
    m_volumeReader.setSourceDeviceMuted(index, muted);
}

void SystemManager::setApplicationVolume(uint32_t pid, int volume)
{
    m_volumeReader.setApplicationVolume(pid, volume);
}

void SystemManager::setDefaultPlaybackDevice(uint32_t index)
{
    m_volumeReader.setDefaultPlaybackDevice(index);
}

void SystemManager::setDefaultInputDevice(uint32_t index)
{
    m_volumeReader.setDefaultInputDevice(index);
}

// Power
// ------------------------------------------------------------

QString SystemManager::powerProfile() const
{
    return m_powerProfile;
}

void SystemManager::setPowerProfile(const QString &profile)
{
    if (profile == "power-saver" ||
        profile == "balanced" ||
        profile == "performance") {

        QProcess::startDetached(
            "powerprofilesctl",
            QStringList() << "set" << profile);

        m_powerProfile = profile;
        emit powerProfileChanged();

        QString settingsKey;
        if (profile == "power-saver") settingsKey = "saver";
        else if (profile == "performance") settingsKey = "perform";
        else settingsKey = "balanced";

        const QVariantMap energy = m_settingsReader.settings().value("energy").toMap();
        const QVariantMap profiles = energy.value("profiles").toMap();
        const QVariantMap p = profiles.value(settingsKey).toMap();

        if (p.contains("brightness")) {
            const int target = p.value("brightness").toInt();
            if (target != m_brightness)
                setBrightness(target);
        }
    }
}

void SystemManager::setBrightness(int percentage)
{
    percentage = std::clamp(percentage, 5, 100);

    QString command =
        QString("brightnessctl set %1%").arg(percentage);

    QProcess::startDetached(
        "/bin/sh",
        QStringList() << "-c" << command);

    m_brightness = percentage;
    emit brightnessChanged();
}

void SystemManager::setBrightnessPersist(int percentage)
{
    setBrightness(percentage);
    persistBrightnessToActiveProfile(percentage);
}

void SystemManager::updateBattery()
{
    QFile capacityFile("/sys/class/power_supply/BAT1/capacity");

    if (capacityFile.open(QIODevice::ReadOnly)) {

        int capacity =
            capacityFile.readAll().trimmed().toInt();

        if (m_batteryCapacity != capacity) {
            m_batteryCapacity = capacity;
            emit batteryCapacityChanged();
        }
    }

    QFile statusFile("/sys/class/power_supply/BAT1/status");

    if (statusFile.open(QIODevice::ReadOnly)) {

        QString status =
            statusFile.readAll().trimmed();

        if (m_batteryStatus != status) {
            m_batteryStatus = status;
            emit batteryStatusChanged();
        }
    }
}

void SystemManager::updateBrightness()
{
    runCommandAsync(
        "brightnessctl",
        {"-m"},
        [this](const QString &output) {

            if (output.isEmpty())
                return;

            QStringList parts = output.split(',');

            if (parts.size() >= 4) {

                int brightness =
                    parts[3].chopped(1).toInt();

                if (m_brightness != brightness) {
                    m_brightness = brightness;
                    emit brightnessChanged();
                }
            }
        });
}

void SystemManager::updatePowerProfile()
{
    QProcess process;

    process.start("powerprofilesctl", {"get"});
    process.waitForFinished(500);

    QString current =
        process.readAllStandardOutput().trimmed();

    if (!current.isEmpty() &&
        current != m_powerProfile) {

        m_powerProfile = current;
        emit powerProfileChanged();
    }
}

void SystemManager::suspend()
{
    QProcess::startDetached("systemctl", {"suspend"});
}

void SystemManager::reboot()
{
    QProcess::startDetached("systemctl", {"reboot"});
}

void SystemManager::powerOff()
{
    QProcess::startDetached("systemctl", {"poweroff"});
}

// Weather
// ------------------------------------------------------------

QString SystemManager::weather() const
{
    return m_weather;
}

// TODAY
//---------------------------------------------------------
void SystemManager::refreshTodayData()
{
    QVariantList newEvents = m_eventsReader.readEvents();
    QVariantList newAgenda = m_agendaReader.readAgenda();
    QVariantMap newStats = m_statsReader.readStats();

    bool changed = false;

    if (m_agenda != newAgenda) {
        m_agenda = newAgenda;
        changed = true;
    }

    if (m_events != newEvents) {
        m_events = newEvents;
        changed = true;
    }

    if (m_userStats != newStats) {
        m_userStats = newStats;
        changed = true;
    }

    if (changed) {
        emit todayDataChanged();
    }

    if (changed) {
        emit todayDataChanged();
    }
}

void SystemManager::toggleAgendaTask(int index) {
    if (index >= 0 && index < m_agenda.size()) {
        QVariantMap task = m_agenda[index].toMap();
        
        task["done"] = !task["done"].toBool(); 
        
        m_agenda[index] = task; 

        m_agendaReader.writeAgenda(m_agenda); 
        
        emit todayDataChanged(); 
    }
}
void SystemManager::addEvent(const QString &date, const QString &title) {
    if (date.isEmpty() || title.isEmpty()) {
        return;
    }

    QVariantMap newEvent;
    newEvent["date"] = date;
    newEvent["title"] = title;

    m_events.append(newEvent);

    m_eventsReader.writeEvents(m_events);

    emit todayDataChanged();
}

void SystemManager::addAgendaTask(const QString &task) {
    if (task.trimmed().isEmpty()) {
        return;
    }

    QVariantMap newTask;
    newTask["task"] = task.trimmed();
    newTask["done"] = false;

    QVariantList tempList = m_agenda;
    tempList.append(newTask);

    m_agenda = tempList;

    m_agendaReader.writeAgenda(m_agenda);
    refreshTodayData();
}


// Workspaces
// ------------------------------------------------------------

void SystemManager::refreshWorkspaces() {
    m_hyprlandReader.readWorkspacesAsync([this](QVariantList newWorkspaces) {
        if (m_workspaces != newWorkspaces) {
            m_workspaces = newWorkspaces;
            emit workspacesChanged();
        }
    });
}

// USB
// ------------------------------------------------------------
void SystemManager::refreshUsbDevices() {
    m_udisksReader.refreshDevices();
}

void SystemManager::mountUsbDevice(const QString &path) {
    m_udisksReader.mountDevice(path);
}

void SystemManager::unmountUsbDevice(const QString &path) {
    m_udisksReader.unmountDevice(path);
}

// Settings
// ------------------------------------------------------------
QVariant SystemManager::getSetting(const QString &key) const {
    return m_settingsReader.get(key);
}

void SystemManager::setSetting(const QString &key, const QVariant &value) {
    m_settingsReader.set(key, value);
}

void SystemManager::resetSettings() {
    m_settingsReader.reset();
}

void SystemManager::applyActiveProfileBrightness()
{
    const QVariantMap settings = m_settingsReader.settings();
    const QVariantMap energy = settings.value("energy").toMap();
    const QString activeProfile = energy.value("active_profile").toString();

    if (activeProfile.isEmpty())
        return;

    const QVariantMap profile = energy.value("profiles").toMap()
                                       .value(activeProfile).toMap();

    QString systemProfile;
    if (activeProfile == "saver") systemProfile = "power-saver";
    else if (activeProfile == "perform") systemProfile = "performance";
    else systemProfile = "balanced";

    if (m_powerProfile != systemProfile) {
        QProcess::startDetached(
            "powerprofilesctl",
            QStringList() << "set" << systemProfile);
        m_powerProfile = systemProfile;
        emit powerProfileChanged();
    }

    if (!profile.contains("brightness"))
        return;

    const int target = profile.value("brightness").toInt();

    if (target != m_brightness) {
        setBrightness(target);
    }
}

void SystemManager::persistBrightnessToActiveProfile(int percentage)
{
    const QVariantMap settings = m_settingsReader.settings();
    const QString activeProfile = settings.value("energy").toMap()
                                           .value("active_profile").toString();

    if (activeProfile.isEmpty())
        return;

    m_settingsReader.set(
        QString("energy.profiles.%1.brightness").arg(activeProfile),
        percentage);
}

// System Info
// ------------------------------------------------------------
void SystemManager::refreshSystemInfo() {
    m_fastfetchReader.refresh();
}

bool SystemManager::doNotDisturb() const
{
    return m_settingsReader.get("display.notifications.do_not_disturb").toBool();
}

void SystemManager::setDoNotDisturb(bool dnd)
{
    if (doNotDisturb() != dnd) {
        m_settingsReader.set("display.notifications.do_not_disturb", dnd);
        emit doNotDisturbChanged();
    }
}

void SystemManager::closeNotification(uint id)
{
    m_notifyReader.CloseNotification(id);
}

// Monitors
// ------------------------------------------------------------
void SystemManager::refreshMonitors() {
    emit systemInfoChanged();
}

QString SystemManager::getMonitorsJson() {
    QProcess proc;
    proc.start("hyprctl", {"monitors", "-j"});
    proc.waitForFinished(3000);
    return QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
}

static QString escapeLuaString(const QString &s) {
    QString out = s;
    out.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    return out;
}

void SystemManager::applyMonitorConfig(const QString &name, const QString &resolution, const QString &rate, int transform, double scale) {
    QString rateStr = rate;
    rateStr.replace(',', '.');
    QString lua = QString("hl.monitor({output=\"%1\", mode=\"%2@%3\", position=\"auto\", scale=%4")
        .arg(escapeLuaString(name), escapeLuaString(resolution), escapeLuaString(rateStr))
        .arg(scale, 0, 'f', 2);
    if (transform != 0)
        lua += QString(", transform=%1").arg(transform);
    lua += "})";
    QProcess proc;
    proc.start("hyprctl", {"eval", lua});
    proc.waitForFinished(3000);
}

void SystemManager::setMonitorEnabled(const QString &name, bool enabled) {
    if (enabled) {
        QProcess getProc;
        getProc.start("hyprctl", {"monitors", "-j"});
        getProc.waitForFinished(3000);
        QByteArray json = getProc.readAllStandardOutput();
        QJsonDocument doc = QJsonDocument::fromJson(json);
        if (doc.isArray()) {
            for (const QJsonValue &val : doc.array()) {
                QJsonObject obj = val.toObject();
                if (obj["name"].toString() == name) {
                    int w = obj["width"].toInt();
                    int h = obj["height"].toInt();
                    double rate = obj["refreshRate"].toDouble();
                    QString lua = QString("hl.monitor({output=\"%1\", mode=\"%2x%3@%4\", position=\"auto\", scale=1, disabled=false})")
                        .arg(escapeLuaString(name)).arg(w).arg(h).arg(qRound(rate));
                    QProcess proc;
                    proc.start("hyprctl", {"eval", lua});
                    proc.waitForFinished(3000);
                    return;
                }
            }
        }
    } else {
        QString lua = QString("hl.monitor({output=\"%1\", disabled=true})").arg(escapeLuaString(name));
        QProcess proc;
        proc.start("hyprctl", {"eval", lua});
        proc.waitForFinished(3000);
    }
}

void SystemManager::setMonitorLayout(const QString &primary, const QString &secondary, const QString &mode) {
    if (mode == "mirror") {
        QString lua = QString("hl.monitor({output=\"%1\", mode=\"preferred\", position=\"auto\", scale=1, mirror=\"%2\"})")
            .arg(escapeLuaString(secondary), escapeLuaString(primary));
        QProcess proc;
        proc.start("hyprctl", {"eval", lua});
        proc.waitForFinished(3000);
    } else if (mode == "extend") {
        QProcess getProc;
        getProc.start("hyprctl", {"monitors", "-j"});
        getProc.waitForFinished(3000);
        QByteArray json = getProc.readAllStandardOutput();
        QJsonDocument doc = QJsonDocument::fromJson(json);
        if (doc.isArray()) {
            QJsonArray arr = doc.array();
            QJsonObject primaryObj;
            for (int i = 0; i < arr.size(); i++) {
                if (arr[i].toObject()["name"].toString() == primary) {
                    primaryObj = arr[i].toObject();
                    break;
                }
            }
            int xOffset = primaryObj["width"].toInt();
            for (int i = 0; i < arr.size(); i++) {
                QJsonObject m = arr[i].toObject();
                if (m["name"].toString() == secondary) {
                    int w = m["width"].toInt();
                    int h = m["height"].toInt();
                    double rate = m["refreshRate"].toDouble();
                    QString lua = QString("hl.monitor({output=\"%1\", mode=\"%2x%3@%4\", position=\"%5x0\", scale=1})")
                        .arg(escapeLuaString(secondary)).arg(w).arg(h).arg(qRound(rate)).arg(xOffset);
                    QProcess proc;
                    proc.start("hyprctl", {"eval", lua});
                    proc.waitForFinished(3000);
                    return;
                }
            }
        }
    } else if (mode == "single") {
        QString lua = QString("hl.monitor({output=\"%1\", disabled=true})").arg(escapeLuaString(secondary));
        QProcess proc;
        proc.start("hyprctl", {"eval", lua});
        proc.waitForFinished(3000);
    }
}

void SystemManager::setMonitorVrr(const QString &name, bool enabled) {
    QString lua = QString("hl.monitor({output=\"%1\", vrr=%2})").arg(escapeLuaString(name), enabled ? "1" : "0");
    QProcess proc;
    proc.start("hyprctl", {"eval", lua});
    proc.waitForFinished(3000);
}

// Update
// ------------------------------------------------------------

void SystemManager::update() {
    static int counter = 0;
    counter++;

    updateCpu();
    updateRam();

    if (counter % 2 == 0) {
        updateBattery();
        updateBrightness();
        updatePowerProfile();
        m_networkReader.updateNetworkStatus([this]() {
            emit networkChanged();
        });
    }

    if (counter % 4 == 0) {
        refreshDiskStats();
        refreshTodayData();
    }
}

// Helpers
// ------------------------------------------------------------

void SystemManager::runCommandAsync(
    const QString &program,
    const QStringList &args,
    std::function<void(const QString &)> callback)
{
    auto *process = new QProcess(this);

    connect(
        process,
        QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
        [process, callback](int exitCode, QProcess::ExitStatus status) {

            if (status == QProcess::NormalExit &&
                exitCode == 0) {

                callback(QString::fromUtf8(
                    process->readAllStandardOutput()).trimmed());
            }

            process->deleteLater();
        });

    process->start(program, args);
}

bool SystemManager::authenticateUser(const QString &username, const QString &password) {
    return m_pamAuth.authenticate(username, password);
}

void SystemManager::setLocked(bool locked)
{
    if (m_locked != locked) {
        m_locked = locked;
        emit lockedChanged();
    }
}

void SystemManager::lockSession()
{
    setLocked(true);
}

void SystemManager::unlockSession()
{
    setLocked(false);
}

QString SystemManager::currentUsername() const {
    QString envUser = qEnvironmentVariable("USER");
    if (!envUser.isEmpty()) return envUser;

    struct passwd *pw = getpwuid(getuid());
    return pw ? QString::fromLocal8Bit(pw->pw_name) : "usuario";
}

QString SystemManager::getWallpaperCachePath(const QString &monitorName) {
    QProcess process;
    
    process.start("awww", {"query"}); 
    process.waitForFinished();
    
    QString output = QString::fromUtf8(process.readAllStandardOutput());

    QString errorOutput = QString::fromUtf8(process.readAllStandardError());
    

    QStringList lines = output.split('\n', Qt::SkipEmptyParts);
    
    for (const QString &line : lines) {
        if (line.contains(monitorName + ":")) {
            int imgIndex = line.indexOf("image: ");
            if (imgIndex != -1) {
                QString realPath = line.mid(imgIndex + 7).trimmed();
                return "file://" + realPath;
            }
            return ""; 
        }
    }
    
    return "";  
}

} // namespace jozet
