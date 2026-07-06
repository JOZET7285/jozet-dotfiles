#pragma once
#include <QObject>
#include <QtQml/qqml.h>
#include <QNetworkAccessManager>
#include <QNetworkReply>

namespace jozet{
    class SystemManager : public QObject
    {
        Q_OBJECT
        QML_ELEMENT
        QML_ADDED_IN_MINOR_VERSION(0)

        Q_PROPERTY(int ramUsage READ ramUsage NOTIFY ramUsageChanged)
        Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
        Q_PROPERTY(int cpuTemp READ cpuTemp NOTIFY cpuTempChanged)
        Q_PROPERTY(double diskUsage READ diskUsage NOTIFY diskUsageChanged)
        Q_PROPERTY(QString weather READ weather NOTIFY weatherChanged)
        Q_PROPERTY(QString uptime READ uptime NOTIFY uptimeChanged)

    public:
        explicit SystemManager(QObject *parent = nullptr);

        int ramUsage() const;
        int cpuUsage() const;
        int cpuTemp() const;
        double diskUsage() const;
        QString weather() const { return m_weather; }
        QString uptime() const;

    signals:
        void ramUsageChanged();
        void cpuUsageChanged();
        void cpuTempChanged();
        void diskUsageChanged();
        void uptimeChanged();
        void weatherChanged();

    private slots:
        void update();
        int readCpuTemperature();
        void fetchWeather();
        void handleNetworkReply(QNetworkReply *reply);

    private:
        QNetworkAccessManager *m_networkManager = nullptr;
        QString m_weather = "Cargando...";
        int m_ramUsage = 0;
        int m_cpuUsage = 0;
        double m_diskUsage = 0.0;
        int m_cpuTemp = 0;
        long m_prevIdle = 0;
        long m_prevTotal = 0;
    };
}