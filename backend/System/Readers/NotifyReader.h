#pragma once

#include <QObject>
#include <QVariantMap>
#include <QStringList>
#include <QtDBus/QDBusConnection>

namespace jozet {

class NotifyReader : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Notifications")

public:
    explicit NotifyReader(QObject *parent = nullptr);

public slots:
    uint Notify(const QString &app_name, uint replaces_id, const QString &app_icon,
                const QString &summary, const QString &body, const QStringList &actions,
                const QVariantMap &hints, int expire_timeout);

    void CloseNotification(uint id);
    QStringList GetCapabilities();
    QString GetServerInformation(QString &vendor, QString &version, QString &spec_version);

signals:
    void notificationReceived(const QVariantMap &notification);
    void notificationClosed(uint id, uint reason);

private:
    uint m_nextId = 1;
};

} // namespace jozet