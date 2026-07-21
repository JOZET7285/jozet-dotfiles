#pragma once
#include <QObject>
#include <QVariantList>
#include <QTimer>

namespace jozet {

struct UsbDevice {
    QString path;
    QString devicePath;
    QString name;
    QString size;
    QString mountPoint;
    bool mounted;
    double percent;
    double totalGb;
    double usedGb;
};

class UdisksReader : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantList devices READ devices NOTIFY devicesChanged)

public:
    explicit UdisksReader(QObject *parent = nullptr);

    QVariantList devices() const;

    Q_INVOKABLE void refreshDevices();
    Q_INVOKABLE void mountDevice(const QString &path);
    Q_INVOKABLE void unmountDevice(const QString &path);

signals:
    void devicesChanged();

private:
    QTimer *m_pollTimer;
    QList<UsbDevice> m_devices;

    void pollDevices();
};

}
