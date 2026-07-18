#include "Readers/NetworkReader.h"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QProcess>
#include <QStringList>
#include <QNetworkInterface>
#include <QHostAddress>
#include <QRegularExpression>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusObjectPath>
#include <QDBusPendingReply>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QVariantList>
#include <QThread>
#include <QCoreApplication>
#include <QDebug>
#include <functional>

namespace jozet {

NetworkReader::NetworkReader() {
    detectInterfaces();
}

void NetworkReader::scanAvailableNetworks(std::function<void(QVariantList)> callback){
    QThread *workerThread = QThread::create([this, callback]() {
        m_networks.clear();

        QDBusInterface nm("org.freedesktop.NetworkManager",
                          "/org/freedesktop/NetworkManager",
                          "org.freedesktop.NetworkManager",
                          QDBusConnection::systemBus());

        QDBusReply<QDBusObjectPath> activeConnPath = nm.call("GetProperty", "PrimaryConnection");
        QString activeSsid = "";
        if (activeConnPath.isValid()) {
            QDBusInterface activeConn("org.freedesktop.NetworkManager", activeConnPath.value().path(),
                                       "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());
            QVariant ssidVar = activeConn.call("Get", "org.freedesktop.NetworkManager.Connection.Active", "Id").arguments().at(0).value<QDBusVariant>().variant();
            activeSsid = ssidVar.toString();
        }

        QDBusReply<QList<QDBusObjectPath>> devices = nm.call("GetDevices");
        if (devices.isValid()) {
            for (const QDBusObjectPath &devicePath : devices.value()) {
                QDBusInterface props("org.freedesktop.NetworkManager", devicePath.path(), "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());

                if (props.call("Get", "org.freedesktop.NetworkManager.Device", "DeviceType").arguments().at(0).value<QDBusVariant>().variant().toUInt() != 2)
                    continue;

                QDBusInterface wifi("org.freedesktop.NetworkManager", devicePath.path(),
                                    "org.freedesktop.NetworkManager.Device.Wireless", QDBusConnection::systemBus());

                wifi.call("RequestScan", QVariantMap());
                QThread::msleep(2500);

                QDBusReply<QList<QDBusObjectPath>> aps = wifi.call("GetAllAccessPoints");
                if (!aps.isValid()) continue;

                for (const QDBusObjectPath &apPath : aps.value()) {
                    QDBusInterface apProps("org.freedesktop.NetworkManager", apPath.path(), "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());

                    QString ssid = QString::fromUtf8(apProps.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Ssid").arguments().at(0).value<QDBusVariant>().variant().toByteArray());
                    if (ssid.isEmpty()) continue;

                    int freq = apProps.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Frequency").arguments().at(0).value<QDBusVariant>().variant().toInt();
                    int strength = apProps.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Strength").arguments().at(0).value<QDBusVariant>().variant().toInt();

                    bool exists = false;
                    for (const auto &n : m_networks) { if (n.ssid == ssid) exists = true; }
                    if (exists) continue;

                    WifiNetwork network;
                    network.ssid = ssid;
                    network.signal = strength;
                    network.frequency = freq;
                    network.connected = (ssid == activeSsid);
                    network.security = "WPA2";

                    m_networks.push_back(network);
                }
                break;
            }
        }

        QVariantList result = availableNetworks();

        QMetaObject::invokeMethod(QCoreApplication::instance(), [callback, result]() {
            if (callback) callback(result);
        }, Qt::QueuedConnection);
    });

    QObject::connect(workerThread, &QThread::finished, workerThread, &QObject::deleteLater);
    workerThread->start();
}

void NetworkReader::connectToWifi(const QString &ssid, const QString &password) {
    QProcess *process = new QProcess(); // Se remueve 'this'
    QStringList args = {"device", "wifi", "connect", ssid, "password", password};
    
    QObject::connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), 
            [process](int, QProcess::ExitStatus) {
        process->deleteLater();
    });
    
    process->start("nmcli", args);
}

QVariantList NetworkReader::availableNetworks() const
{
    QVariantList list;
    for (const auto &network : m_networks) {
        QVariantMap map;
        map["ssid"] = network.ssid;
        map["signal"] = network.signal;
        map["connected"] = network.connected;
        map["security"] = network.security;
        map["frequency"] = network.frequency;
        list.append(map);
    }
    return list;
}

QString NetworkReader::getAddress(const QString &iface)
{
    QNetworkInterface net = QNetworkInterface::interfaceFromName(iface);
    for (const auto &entry : net.addressEntries()) {
        if (entry.ip().protocol() == QAbstractSocket::IPv4Protocol)
            return entry.ip().toString();
    }
    return "";
}

QString NetworkReader::getWifiFreq(const QString &iface) {
    QProcess process;
    process.start("/usr/bin/iw", {"dev", iface, "info"});
    
    if (runProcess(process, 800)) {
        QString output = process.readAllStandardOutput();
        static const QRegularExpression re("channel \\d+ \\((\\d+ MHz)\\)");
        QRegularExpressionMatch match = re.match(output);
        if (match.hasMatch()) {
            return match.captured(1);
        }
    }
    return "N/A";
}

bool NetworkReader::runProcess(QProcess &process, int timeoutMs) {
    if (process.waitForFinished(timeoutMs)) {
        return true;
    }
    process.kill();
    process.waitForFinished(200);
    return false;
}

int NetworkReader::getWifiQuality(const QString &iface) {
    QFile file("/proc/net/wireless");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString content = QString::fromUtf8(file.readAll());
        file.close();
        
        QStringList lines = content.split('\n', Qt::SkipEmptyParts);
        for (const QString &line : lines) {
            if (line.contains(iface + ":")) {
                QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
                for (int i = 0; i < parts.size(); ++i) {
                    if (parts[i].contains(".")) {
                        QString qualStr = parts[i];
                        qualStr.remove('.');
                        return qualStr.toInt();
                    }
                }
            }
        }
    }
    return 0;
}

QString NetworkReader::readSysFile(const QString &iface, const QString &file) {
    if (iface.isEmpty()) return "N/A";
    QFile f("/sys/class/net/" + iface + "/" + file);
    if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return f.readAll().trimmed();
    }
    return "N/A";
}

QString NetworkReader::getSpeed(const QString &iface, InterfaceType type) {
    if (iface.isEmpty()) return "N/A";

    if (type == InterfaceType::ethernet) {
        QFile speedFile("/sys/class/net/" + iface + "/speed");
        if (speedFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QString speed = speedFile.readAll().trimmed();
            if (speed != "-1") return speed + " Mbps";
        }
    } 
    else if (type == InterfaceType::wifi) {
        QProcess process;
        process.start("/usr/bin/iw", {"dev", iface, "link"});
        if (runProcess(process, 800)) {
            QString output = process.readAllStandardOutput();
            static const QRegularExpression re("tx bitrate: ([0-9.]+)");
            QRegularExpressionMatch match = re.match(output);
            if (match.hasMatch()) {
                return match.captured(1) + " Mbps";
            }
        }
    }
    
    return "N/A";
}

QString NetworkReader::getWifiSsid(const QString &iface)
{
    QProcess process;
    process.start("nmcli", {"-t", "-g", "GENERAL.CONNECTION", "device", "show", iface});

    if (!runProcess(process, 1000))
        return "No conectado";

    QString ssid = process.readAllStandardOutput().trimmed();
    if (ssid.isEmpty() || ssid == "--")
        return "No conectado";

    return ssid;
}

void NetworkReader::detectInterfaces() {
    QDir netDir("/sys/class/net");
    QStringList interfaces = netDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    
    for (const QString &iface : interfaces) {
        if (iface.startsWith("en") || iface.startsWith("eth")) m_ethInterface = iface;
        else if (iface.startsWith("wl")) m_wifiInterface = iface;
    }
}

void NetworkReader::updateNetworkStatus(std::function<void()> callback) {
    if (m_ethInterface.isEmpty() && m_wifiInterface.isEmpty()) return;

    QThread *workerThread = QThread::create([this, callback]() {
        NetInfo tempEth = m_eth;
        NetInfo tempWifi = m_wifi;

        auto updateInfo = [&](NetInfo &info, const QString &iface) {
            if (iface.isEmpty()) return;
            
            info.name = iface;
            info.status = readSysFile(iface, "operstate");
            
            if (iface.startsWith("wl")) { 
                QString ssid = getWifiSsid(iface);
                info.name = ssid.isEmpty() ? "WiFi (Desconectado)" : ssid;
                info.type = InterfaceType::wifi;
                info.speed = getSpeed(iface, InterfaceType::wifi);
                info.freq = getWifiFreq(iface);
                info.qual = getWifiQuality(iface);
            } else if (iface.startsWith("en") || iface.startsWith("eth")) {
                info.name = "Ethernet";
                info.type = InterfaceType::ethernet;
                info.speed = getSpeed(iface, InterfaceType::ethernet);
            } 
            info.address = getAddress(iface);
        };

        updateInfo(tempEth, m_ethInterface);
        updateInfo(tempWifi, m_wifiInterface);

        QMetaObject::invokeMethod(QCoreApplication::instance(), [this, tempEth, tempWifi, callback]() {
            m_eth = tempEth;
            m_wifi = tempWifi;
            if(callback) callback();
        }, Qt::QueuedConnection);
    });

    QObject::connect(workerThread, &QThread::finished, workerThread, &QObject::deleteLater);
    workerThread->start();
}

static QString interfaceTypeToString(InterfaceType type)
{
    switch (type) {
    case InterfaceType::ethernet: return "ethernet";
    case InterfaceType::wifi: return "wifi";
    default: return "unknown";
    }
}

QVariantMap NetworkReader::ethernetInfo() const {
    return QVariantMap{
        {"name", m_eth.name},
        {"type", interfaceTypeToString(m_eth.type)}, 
        {"status", m_eth.status}, 
        {"speed", m_eth.speed},
        {"address", m_eth.address}};
}

QVariantMap NetworkReader::wifiInfo() const {
    return QVariantMap{
        {"name", m_wifi.name}, 
        {"type", interfaceTypeToString(m_wifi.type)},
        {"status", m_wifi.status}, 
        {"speed", m_wifi.speed},
        {"address", m_wifi.address},
        {"freq", m_wifi.freq},
        {"qual", m_wifi.qual}};
}

}