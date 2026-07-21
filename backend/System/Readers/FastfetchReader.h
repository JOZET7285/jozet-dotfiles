#pragma once
#include <QObject>
#include <QVariantMap>
#include <QTimer>

namespace jozet {

class FastfetchReader : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantMap systemInfo READ systemInfo NOTIFY systemInfoChanged)

public:
    explicit FastfetchReader(QObject *parent = nullptr);

    QVariantMap systemInfo() const;

    Q_INVOKABLE void refresh();

signals:
    void systemInfoChanged();

private:
    QTimer *m_timer;
    QVariantMap m_info;

    void fetch();
};

}
