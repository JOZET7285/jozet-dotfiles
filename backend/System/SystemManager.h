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

namespace jozet {
    class SystemManager : public QObject
    {
        Q_OBJECT
        QML_ELEMENT
        QML_ADDED_IN_MINOR_VERSION(0)

        Q_PROPERTY(int ramUsage READ ramUsage NOTIFY ramUsageChanged)
        Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
        Q_PROPERTY(double diskUsage READ diskUsage NOTIFY diskUsageChanged)
        Q_PROPERTY(int cpuTemp READ cpuTemp NOTIFY cpuTempChanged)
        Q_PROPERTY(QString weather READ weather NOTIFY weatherChanged)
        Q_PROPERTY(QVariantList availableNetworks READ availableNetworks NOTIFY networkChanged)
        Q_PROPERTY(QVariantMap ethernetInfo READ ethernetInfo NOTIFY networkChanged)
        Q_PROPERTY(QVariantMap wifiInfo READ wifiInfo NOTIFY networkChanged)

    public:
        explicit SystemManager(QObject *parent = nullptr);

        int ramUsage() const;
        int cpuUsage() const;
        double diskUsage() const;
        int cpuTemp() const;
        QString weather() const;
        QVariantMap ethernetInfo() const { return m_networkReader.ethernetInfo(); }
        QVariantMap wifiInfo() const { return m_networkReader.wifiInfo(); }
        Q_INVOKABLE QVariantList availableNetworks() const { return m_networkReader.availableNetworks(); }
        Q_INVOKABLE void scanNetworks() { m_networkReader.scanAvailableNetworks(); }
        Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password) {
            m_networkReader.connectToWifi(ssid, password);
        }

    signals:
        void ramUsageChanged();
        void cpuUsageChanged();
        void diskUsageChanged();
        void cpuTempChanged();
        void weatherChanged();
        void networkChanged();

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
        TempReader m_tempReader;
        NetworkReader m_networkReader;

        QNetworkAccessManager *m_networkManager = nullptr;
    };
}