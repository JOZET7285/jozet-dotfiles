#include "HyprlandReader.h"
#include <QProcess>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

namespace jozet {

QVariantList HyprlandReader::readWorkspaces() {
    QVariantList workspacesData;
    
    QProcess process;
    process.start("hyprctl", {"clients", "-j"});
    process.waitForFinished(1000);
    
    QByteArray output = process.readAllStandardOutput();
    QJsonDocument doc = QJsonDocument::fromJson(output);
    
    if (!doc.isArray()) return workspacesData;
    
    QJsonArray clients = doc.array();
    
    QMap<int, QVariantList> workspaceApps;
    
    for (const QJsonValue &value : clients) {
        QJsonObject client = value.toObject();
        int workspaceId = client["workspace"].toObject()["id"].toInt();
        
        QVariantMap appData;
        appData["address"] = client["address"].toString();
        appData["class"] = client["class"].toString();
        appData["title"] = client["title"].toString();
        
        workspaceApps[workspaceId].append(appData);
    }
    
    for (auto it = workspaceApps.constBegin(); it != workspaceApps.constEnd(); ++it) {
        QVariantMap wsData;
        wsData["id"] = it.key();
        wsData["apps"] = it.value();
        workspacesData.append(wsData);
    }
    
    return workspacesData;
}

void HyprlandReader::moveWindowToWorkspace(const QString &windowAddress, int workspaceId) {
    QString command = QString("hyprctl dispatch movetoworkspacesilent %1,address:%2")
                      .arg(workspaceId)
                      .arg(windowAddress);
                      
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << command);
}

}