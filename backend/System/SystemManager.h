#pragma once
#include <QObject>
#include <QtQml/qqml.h>
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
        Q_PROPERTY(QString uptime READ uptime NOTIFY uptimeChanged)

    public:
        explicit SystemManager(QObject *parent = nullptr);

        int ramUsage() const;
        int cpuUsage() const;
        int cpuTemp() const;
        double diskUsage() const;
        QString uptime() const;

    signals:
        void ramUsageChanged();
        void cpuUsageChanged();
        void cpuTempChanged();
        void diskUsageChanged();
        void uptimeChanged();

    private slots:
        void update();
        int readCpuTemperature();

    private:
        int m_ramUsage = 0;
        int m_cpuUsage = 0;
        double m_diskUsage = 0.0;
        int m_cpuTemp = 0;
        long m_prevIdle = 0;
        long m_prevTotal = 0;
    };
}