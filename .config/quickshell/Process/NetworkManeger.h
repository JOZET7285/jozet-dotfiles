#include <QObject>
#include <QString>

class NetworkManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString netStatus READ netStatus NOTIFY netStatusChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr);
    QString netStatus() const { return m_netStatus; }

public slots:
    void updateNetworkStatus();

signals:
    void netStatusChanged();

private:
    QString m_netStatus;
};