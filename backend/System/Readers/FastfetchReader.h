#pragma once
#include <QObject>
#include <QVariantMap>

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
    QVariantMap m_info;
    bool m_fetching = false;

    void fetch();
    void parseOutput(const QByteArray &output);
};

}
