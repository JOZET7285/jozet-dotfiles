#pragma once
#include <QString>
#include <QDir>
#include <QFile>
#include <QVariantMap>
#include <vector>
#include <QProcess>

namespace jozet {
    enum class InterfaceType {
        unknown,
        ethernet,
        wifi
    };

    struct NetInfo {
        QString name;
        InterfaceType type = InterfaceType::unknown;
        QString status;
        QString speed;
        QString address;
        QString freq;
        int qual;
    };
  
    struct WifiNetwork {
        QString ssid;
        int signal;
        bool connected;
        QString security;
        int frequency;
    };

    class NetworkReader {
    public:
        NetworkReader();
        void updateNetworkStatus(std::function<void()> callback = nullptr);
        QVariantMap ethernetInfo() const;
        QVariantMap wifiInfo() const;
        Q_INVOKABLE QVariantList availableNetworks() const;
        void scanAvailableNetworks(std::function<void(QVariantList)> callback);
        void connectToWifi(const QString &ssid, const QString &password);

    private:
        void detectInterfaces();
        QString readSysFile(const QString &iface, const QString &file);
        QString getWifiSsid(const QString &iface);
        QString getAddress(const QString &iface);
        QString getSpeed(const QString &iface, InterfaceType type);
        int getWifiQuality(const QString &iface);
        QString getWifiFreq(const QString &iface);
        static bool runProcess(QProcess &process, int timeoutMs);
        
        QString m_ethInterface;
        QString m_wifiInterface;
        NetInfo m_eth;
        NetInfo m_wifi;
        std::vector<WifiNetwork> m_networks;
    };
}