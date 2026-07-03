#include "NetworkManager.h"
#include <QNetworkInterface>

void NetworkManager::updateNetworkStatus() {
    QString newStatus = "Desconectado";
    const QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    
    for (const QNetworkInterface &iface : interfaces) {
        if (iface.flags().testFlag(QNetworkInterface::IsUp) && !iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            newStatus = iface.name().startsWith("e") ? "Ethernet" : "Wi-Fi";
            break;
        }
    }

    if (m_netStatus != newStatus) {
        m_netStatus = newStatus;
        emit netStatusChanged();
    }
}