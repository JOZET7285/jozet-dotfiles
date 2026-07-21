#include "HyprlandReader.h"
#include <QLocalSocket>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>
#include <QFile>
#include <QTimer>
#include <QDebug>

namespace jozet {

void HyprlandReader::readWorkspacesAsync(std::function<void(QVariantList)> callback) {
    QString signature = qEnvironmentVariable("HYPRLAND_INSTANCE_SIGNATURE");

    if (signature.isEmpty()) {
        callback(QVariantList());
        return;
    }

    QString runtimeDir = qEnvironmentVariable("XDG_RUNTIME_DIR");
    QString socketPath = runtimeDir.isEmpty()
        ? "/tmp/hypr/" + signature + "/.socket.sock"
        : runtimeDir + "/hypr/" + signature + "/.socket.sock";

    if (!QFile::exists(socketPath)) {
        socketPath = "/tmp/hypr/" + signature + "/.socket.sock";
    }

    auto *socket = new QLocalSocket();
    auto buffer = std::make_shared<QByteArray>();
    auto finished = std::make_shared<bool>(false);

    auto finish = [socket, callback, buffer, finished](QByteArray data) {
        if (*finished) return;
        *finished = true;
        socket->deleteLater();

        QVariantList workspacesData;
        QJsonDocument doc = QJsonDocument::fromJson(data);

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
    };

    QObject::connect(socket, &QLocalSocket::connected, [socket]() {
        socket->write("j/clients");
        socket->flush();
    });

   QObject::connect(socket, &QLocalSocket::disconnected, [socket, buffer, finish]() {
        buffer->append(socket->readAll());
        finish(*buffer);
    });
    
    QObject::connect(socket, &QLocalSocket::errorOccurred, [socket, buffer, finish](QLocalSocket::LocalSocketError err) {
        buffer->append(socket->readAll());
        finish(*buffer);
    });

    QObject::connect(socket, &QLocalSocket::errorOccurred, [finish](QLocalSocket::LocalSocketError err) {
        finish(QByteArray());
    });

    QTimer::singleShot(2000, socket, [finish]() {
        finish(QByteArray());
    });

    socket->connectToServer(socketPath);
}

HyprlandReader::HyprlandReader(QObject *parent) : QObject(parent) {
    connectEventSocket();
}

void HyprlandReader::connectEventSocket() {
    QString signature = qEnvironmentVariable("HYPRLAND_INSTANCE_SIGNATURE");
    if (signature.isEmpty()) return;

    QString runtimeDir = qEnvironmentVariable("XDG_RUNTIME_DIR");
    QString socketPath = runtimeDir.isEmpty()
        ? "/tmp/hypr/" + signature + "/.socket2.sock"
        : runtimeDir + "/hypr/" + signature + "/.socket2.sock";

    if (!QFile::exists(socketPath)) {
        socketPath = "/tmp/hypr/" + signature + "/.socket2.sock";
    }

    m_eventSocket = new QLocalSocket(this);

    connect(m_eventSocket, &QLocalSocket::readyRead, this, [this]() {
        m_eventBuffer.append(m_eventSocket->readAll());

        int newlineIndex;
        while ((newlineIndex = m_eventBuffer.indexOf('\n')) != -1) {
            QByteArray line = m_eventBuffer.left(newlineIndex);
            m_eventBuffer.remove(0, newlineIndex + 1);

            static const QList<QByteArray> relevantEvents = {
                "workspace>>", "workspacev2>>", "moveworkspace>>",
                "movewindow>>", "openwindow>>", "closewindow>>",
                "changefloatingmode>>"
            };

            for (const auto &prefix : relevantEvents) {
                if (line.startsWith(prefix)) {
                    emit workspacesShouldRefresh();
                    break;
                }
            }
        }
    });

    connect(m_eventSocket, &QLocalSocket::disconnected, this, [this]() {
        QTimer::singleShot(2000, this, [this]() { connectEventSocket(); });
    });

    m_eventSocket->connectToServer(socketPath);
}

}