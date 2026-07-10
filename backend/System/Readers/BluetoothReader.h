#pragma once
#include <QObject>
#include <QVariantList>
#include <QProcess>
#include <QString>
#include <QStringList>
#include <vector>

namespace jozet {

struct BtDevice {
    QString name;
    QString address;
    bool connected;
    int rssi;
};

class BluetoothReader : public QObject {
    Q_OBJECT 

    Q_PROPERTY(QVariantList availableDevices READ availableDevices NOTIFY devicesChanged)

public:
    explicit BluetoothReader(QObject *parent = nullptr);
    ~BluetoothReader();
    
    Q_INVOKABLE void setPower(bool on);
    Q_INVOKABLE void scan(bool start);
    Q_INVOKABLE void connectDevice(const QString &address);
    Q_INVOKABLE void disconnectDevice(const QString &address);
    Q_INVOKABLE void forgetDevice(const QString &address);
    Q_INVOKABLE void updateDevices();
    
    QVariantList availableDevices() const;

signals:
    void devicesChanged();

private slots:
    void handleBluetoothOutput();
    void onConnectTimeout();

private:
    std::vector<BtDevice> m_devices;
    QProcess *m_process;
    bool m_scanWasActive = false;

    QString cleanQString(const QString& row);
    QString getConnectedDeviceData(const QString& deviceData, const QString& key);
    QString getDeviceAddress(const QString& deviceData);
    void parseCurrentStatus(const QString& output);
};

}
