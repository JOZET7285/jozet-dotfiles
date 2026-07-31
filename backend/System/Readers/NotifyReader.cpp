#include "NotifyReader.h"
#include <QDebug>

namespace jozet {

NotifyReader::NotifyReader(QObject *parent) : QObject(parent)
{
    QDBusConnection session = QDBusConnection::sessionBus();
    
    if (!session.registerService("org.freedesktop.Notifications")) {
        qWarning() << "[NotifyReader] No se pudo registrar el servicio. ¿Hay otro demonio de notificaciones activo?";
    }
    
    if (!session.registerObject("/org/freedesktop/Notifications", this,
                                QDBusConnection::ExportAllSlots | QDBusConnection::ExportAllSignals)) {
        qWarning() << "[NotifyReader] No se pudo registrar el objeto D-Bus.";
    }
}

uint NotifyReader::Notify(const QString &app_name, uint replaces_id, const QString &app_icon,
                          const QString &summary, const QString &body, const QStringList &actions,
                          const QVariantMap &hints, int expire_timeout)
{
    uint id = (replaces_id == 0) ? m_nextId++ : replaces_id;

    QVariantMap notif;
    notif["id"] = id;
    notif["appName"] = app_name;
    notif["appIcon"] = app_icon;
    notif["summary"] = summary;
    notif["body"] = body;
    notif["expireTimeout"] = expire_timeout;
    notif["actions"] = actions; 

    emit notificationReceived(notif);

    return id;
}

void NotifyReader::CloseNotification(uint id)
{
    emit notificationClosed(id, 2); // NotificationDismissedByUser
}

QStringList NotifyReader::GetCapabilities()
{
    return QStringList() << "body" << "actions" << "icon-static";
}

QString NotifyReader::GetServerInformation(QString &vendor, QString &version, QString &spec_version)
{
    vendor = "jozet";
    version = "1.0";
    spec_version = "1.2";
    return "Jozet Notification Server";
}

} // namespace jozet