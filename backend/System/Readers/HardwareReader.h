#pragma once

#include <QObject>
#include <QVariantMap>

namespace jozet {

class HardwareReader : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantMap systemInfo READ systemInfo NOTIFY systemInfoChanged)

public:
    explicit HardwareReader(QObject *parent = nullptr);

    QVariantMap systemInfo() const;

    Q_INVOKABLE void refresh();

signals:
    void systemInfoChanged();

private:
    QVariantMap m_info;

    void fetch();
    void readOsAndKernel(QVariantMap &info);
    void readCpu(QVariantMap &info);
    void readMemoryTotal(QVariantMap &info);
    void readMotherboard(QVariantMap &info);
    void readGpu(QVariantMap &info);
    void readUserAndShell(QVariantMap &info);
    void readWindowManager(QVariantMap &info);
};

}