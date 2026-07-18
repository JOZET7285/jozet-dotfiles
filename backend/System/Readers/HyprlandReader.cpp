#include "HyprlandReader.h"
#include <QLocalSocket>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>

namespace jozet {

void HyprlandReader::readWorkspacesAsync(std::function<void(QVariantList)> callback) {
    QString signature = qEnvironmentVariable("HYPRLAND_INSTANCE_SIGNATURE");
    if (signature.isEmpty()) {
        callback(QVariantList());
        return;
    }

    QString socketPath = "/tmp/hypr/" + signature + "/.socket.sock";
    QLocalSocket *socket = new QLocalSocket();

    QObject::connect(socket, &QLocalSocket::connected, [socket]() {
        socket->write("j/clients");
        socket->flush();
    });

    QObject::connect(socket, &QLocalSocket::readyRead, [socket, callback]() {
        QByteArray output = socket->readAll();
        socket->disconnectFromServer();
        socket->deleteLater();

        QVariantList workspacesData;
        QJsonDocument doc = QJsonDocument::fromJson(output);

        if (!doc.isArray()) {
            callback(workspacesData);
            return;
        }

        QJsonArray clients = doc.array();
        QMap<int, QVariantList> workspaceApps;

        for (const QJsonValue &value : clients) {
            QJsonObject client = value.toObject();
            int workspaceId = client["workspace"].toObject()["id"].toInt();

            QVariantMap appData;
            appData["address"] = client["address"].toString();
            appData["class"] = client["class"].toString();
            appData["title"] = client["title"].toString();
            appData["x"] = client["at"].toArray()[0].toInt();
            appData["y"] = client["at"].toArray()[1].toInt();
            appData["w"] = client["size"].toArray()[0].toInt();
            appData["h"] = client["size"].toArray()[1].toInt();

            workspaceApps[workspaceId].append(appData);
        }

        for (auto it = workspaceApps.constBegin(); it != workspaceApps.constEnd(); ++it) {
            QVariantMap wsData;
            wsData["id"] = it.key();
            wsData["apps"] = it.value();
            workspacesData.append(wsData);
        }

        callback(workspacesData);
    });

    QObject::connect(socket, &QLocalSocket::errorOccurred, [socket, callback](QLocalSocket::LocalSocketError) {
        socket->deleteLater();
        callback(QVariantList());
    });

    socket->connectToServer(socketPath);
}

}