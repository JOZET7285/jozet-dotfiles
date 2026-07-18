#include "System/SystemManager.h"

#include <QDebug>
#include <QNetworkRequest>
#include <QProcess>
#include <QThread>
#include <QTimer>
#include <QUrl>
#include <QDir>

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

                if (!tempPartitions.isEmpty()) {
                    m_diskUsage = tempPartitions[0].toMap()["percent"].toDouble();
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

void SystemManager::connectToNetwork(const QString &ssid, const QString &password)
{
    m_networkReader.connectToWifi(ssid, password);
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

} // namespace jozet