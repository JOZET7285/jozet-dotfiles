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

namespace jozet {

NetworkReader::NetworkReader() {
    detectInterfaces();
}

QVariantList NetworkReader::scanAvailableNetworks()
{
    m_networks.clear();

    QDBusInterface nm("org.freedesktop.NetworkManager",
                      "/org/freedesktop/NetworkManager",
                      "org.freedesktop.NetworkManager",
                      QDBusConnection::systemBus());

    QDBusReply<QDBusObjectPath> activeConnPath = nm.call("GetProperty", "PrimaryConnection");
    QString activeSsid = "";
    if (activeConnPath.isValid()) {
        QDBusInterface activeConn( "org.freedesktop.NetworkManager", activeConnPath.value().path(), 
                                   "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());
        QVariant ssidVar = activeConn.call("Get", "org.freedesktop.NetworkManager.Connection.Active", "Id").arguments().at(0).value<QDBusVariant>().variant();
        activeSsid = ssidVar.toString();
    }

    QDBusReply<QList<QDBusObjectPath>> devices = nm.call("GetDevices");
    if (!devices.isValid()) return availableNetworks();

    for (const QDBusObjectPath &devicePath : devices.value()) {
        QDBusInterface props("org.freedesktop.NetworkManager", devicePath.path(), "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());
        
        if (props.call("Get", "org.freedesktop.NetworkManager.Device", "DeviceType").arguments().at(0).value<QDBusVariant>().variant().toUInt() != 2)
            continue;

        QDBusInterface wifi("org.freedesktop.NetworkManager", devicePath.path(), "org.freedesktop.NetworkManager.Device.Wireless", QDBusConnection::systemBus());
        QDBusReply<QList<QDBusObjectPath>> aps = wifi.call("GetAllAccessPoints");

        if (!aps.isValid()) continue;

        for (const QDBusObjectPath &apPath : aps.value()) {
            QDBusInterface apProps("org.freedesktop.NetworkManager", apPath.path(), "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());
            
            QString ssid = QString::fromUtf8(apProps.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Ssid").arguments().at(0).value<QDBusVariant>().variant().toByteArray());            
            
            if (ssid.isEmpty()) continue;

            int freq = apProps.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Frequency").arguments().at(0).value<QDBusVariant>().variant().toInt();

            int strength = apProps.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Strength").arguments().at(0).value<QDBusVariant>().variant().toInt();

            bool exists = false;
            for(const auto &n : m_networks) { if(n.ssid == ssid) exists = true; }
            if(exists) continue;
            
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

    return availableNetworks();
}

void NetworkReader::connectToWifi(const QString &ssid, const QString &password) {
    QProcess process;
    QStringList args = {"device", "wifi", "connect", ssid, "password", password};
    process.start("nmcli", args);
    process.waitForFinished();
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
    
    if (process.waitForFinished(500)) {
        QString output = process.readAllStandardOutput();
        QRegularExpression re("channel \\d+ \\((\\d+ MHz)\\)");
        QRegularExpressionMatch match = re.match(output);
        if (match.hasMatch()) {
            return match.captured(1);
        }
    }
    return "N/A";
}

int NetworkReader::getWifiQuality(const QString &iface) {
    QProcess process;
    process.start("nmcli", {"-t", "-f", "IN-USE,BARS,SIGNAL", "dev", "wifi"});
    
    if (process.waitForFinished(500)) {
        QStringList lines = QString(process.readAllStandardOutput()).split('\n');
        for (const QString &line : lines) {
            if (line.startsWith("*")) {
                QStringList parts = line.split(':');
                if (parts.size() >= 3) {
                    return parts.last().toInt();
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
        if (process.waitForFinished(500)) {
            QString output = process.readAllStandardOutput();
            QRegularExpression re("tx bitrate: ([0-9.]+)");
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

    process.start("nmcli", {
        "-t",
        "-g",
        "GENERAL.CONNECTION",
        "device",
        "show",
        iface
    });

    if (!process.waitForFinished(1000))
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

void NetworkReader::updateNetworkStatus() {
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

    updateInfo(m_eth, m_ethInterface);
    updateInfo(m_wifi, m_wifiInterface);
}
static QString interfaceTypeToString(InterfaceType type)
{
    switch (type) {
    case InterfaceType::ethernet:
        return "ethernet";
    case InterfaceType::wifi:
        return "wifi";
    default:
        return "unknown";
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