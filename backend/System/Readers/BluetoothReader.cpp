#include "BluetoothReader.h"
#include <QDebug>
#include <QProcess>
#include <QTimer>

namespace jozet {

BluetoothReader::BluetoothReader(QObject *parent) : QObject(parent) {
}

BluetoothReader::~BluetoothReader() {
}

void BluetoothReader::setPower(bool on) {
    QProcess::startDetached("bluetoothctl", {"power", on ? "on" : "off"});
}

void BluetoothReader::scan(bool start) {
    QProcess::startDetached("bluetoothctl", {"scan", start ? "on" : "off"});
}

void BluetoothReader::connectDevice(const QString &address) {
    // Intentar detener el scan (ignore si falla)
    QProcess *stopScanProcess = new QProcess();
    stopScanProcess->setProcessChannelMode(QProcess::MergedChannels);
    stopScanProcess->start("bluetoothctl", {"scan", "off"});
    stopScanProcess->waitForFinished(1000);
    stopScanProcess->deleteLater();
    
    // Esperar un poco para que se complete el stop scan
    QTimer::singleShot(300, this, [this, address]() {
        QProcess *connectProcess = new QProcess(this);
        connectProcess->setProcessChannelMode(QProcess::MergedChannels);
        
        connect(connectProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                this, [this, connectProcess, address](int exitCode, QProcess::ExitStatus status) {
            QString output = connectProcess->readAllStandardOutput();
            qDebug() << "Bluetooth connect result:" << output;
            
            if (status == QProcess::NormalExit && (exitCode == 0 || output.contains("Connected"))) {
                qDebug() << "Bluetooth connection successful to:" << address;
            } else {
                qDebug() << "Bluetooth connect warning:" << output;
            }
            
            // Esperar a que se establezca la conexión completamente
            QTimer::singleShot(2000, this, [this]() {
                updateDevices();
                // Reanudar scan
                QProcess::startDetached("bluetoothctl", {"scan", "on"});
            });
            
            connectProcess->deleteLater();
        });
        
        connectProcess->start("bluetoothctl", {"connect", address});
    });
}

void BluetoothReader::disconnectDevice(const QString &address) {
    QProcess::startDetached("bluetoothctl", {"disconnect", address});
}

void BluetoothReader::forgetDevice(const QString &address) {
    QProcess::startDetached("bluetoothctl", {"remove", address});
}

void BluetoothReader::updateDevices() {
    QProcess *processAll = new QProcess(this);
    
    connect(processAll, &QProcess::finished, this, [this, processAll](int exitCode, QProcess::ExitStatus status) {
        if (status == QProcess::NormalExit && exitCode == 0) {
            QString outputAll = processAll->readAllStandardOutput();
            
            QProcess *processConnected = new QProcess(this);
            
            connect(processConnected, &QProcess::finished, this, [this, outputAll, processConnected](int cExitCode, QProcess::ExitStatus cStatus) {
                if (cStatus == QProcess::NormalExit && cExitCode == 0) {
                    QString outputConnected = processConnected->readAllStandardOutput();
                    
                    QSet<QString> connectedAddresses;
                    QStringList cLines = outputConnected.split('\n');
                    for (const QString& line : cLines) {
                        if (line.contains("Device ")) {
                            QStringList tokens = line.split(' ', Qt::SkipEmptyParts);
                            if (tokens.size() >= 2) {
                                connectedAddresses.insert(tokens[1]);
                            }
                        }
                    }
                    m_devices.clear();
                    QStringList linesAll = outputAll.split('\n');
                    for (const QString& line : linesAll) {
                        if (line.contains("Device ")) {
                            QStringList tokens = line.split(' ', Qt::SkipEmptyParts);
                            if (tokens.size() >= 3) {
                                BtDevice device;
                                device.address = tokens[1];
                                device.name = tokens.mid(2).join(" ");
                                
                                device.connected = connectedAddresses.contains(device.address);
                                device.rssi = 0;
                                
                                m_devices.push_back(device);
                            }
                        }
                    }
                    
                    emit devicesChanged();
                }
                processConnected->deleteLater();
            });
            
            processConnected->start("bluetoothctl", {"devices", "Connected"});
        }
        processAll->deleteLater();
    });

    processAll->start("bluetoothctl", {"devices"});
}



QString BluetoothReader::cleanQString(const QString& row) {
    return row.trimmed();
}

QString BluetoothReader::getConnectedDeviceData(const QString& deviceData, const QString& key) {
    QStringList lines = deviceData.split('\n');
    QString searched = key + ":";

    for (const QString& line : lines) {
        int pos = line.indexOf(searched);
        if (pos != -1) {
            QString value = line.mid(pos + searched.length());
            return cleanQString(value);
        }
    }
    return "";
}

QString BluetoothReader::getDeviceAddress(const QString& deviceData) {
    QStringList lines = deviceData.split('\n');
    for (const QString& line : lines) {
        if (line.contains("Device ")) {
            QStringList tokens = line.split(' ', Qt::SkipEmptyParts);
            if (tokens.size() >= 2) {
                return tokens[1];
            }
        }
    }
    return "";
}

QVariantList BluetoothReader::availableDevices() const {
    QVariantList list;
    for (const auto &dev : m_devices) {
        QVariantMap map;
        map["name"] = dev.name;
        map["address"] = dev.address;
        map["connected"] = dev.connected;
        map["rssi"] = dev.rssi;
        list.append(map);
    }
    return list;
}

void BluetoothReader::handleBluetoothOutput() {}
void BluetoothReader::parseCurrentStatus(const QString&) {}
void BluetoothReader::onConnectTimeout() {}

}
