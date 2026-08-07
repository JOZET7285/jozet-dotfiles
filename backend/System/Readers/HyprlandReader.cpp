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

    auto *monitorSocket = new QLocalSocket();
    auto monitorBuffer = std::make_shared<QByteArray>();

    auto requestClients = [socketPath, callback, monitorBuffer]() {
        QJsonDocument monitorDoc = QJsonDocument::fromJson(*monitorBuffer);
        QJsonArray monitorsArray = monitorDoc.isArray() ? monitorDoc.array() : QJsonArray();

        QMap<QString, QVariantMap> monitorsMap;
        for (const QJsonValue &value : monitorsArray) {
            QJsonObject monitorObj = value.toObject();
            QVariantMap monitorData;
            QString monitorName = monitorObj["name"].toString();
            monitorData["id"] = monitorObj["id"].toInt();
            monitorData["width"] = monitorObj["width"].toInt();
            monitorData["height"] = monitorObj["height"].toInt();
            monitorData["x"] = monitorObj["x"].toInt();
            monitorData["y"] = monitorObj["y"].toInt();
            monitorsMap[monitorName] = monitorData;
        }

        auto *clientSocket = new QLocalSocket();
        auto clientBuffer = std::make_shared<QByteArray>();

        auto processData = [callback, monitorsMap, clientBuffer, clientSocket]() {
            clientSocket->deleteLater();
            
            QJsonDocument clientDoc = QJsonDocument::fromJson(*clientBuffer);
            QJsonArray clientsArray = clientDoc.isArray() ? clientDoc.array() : QJsonArray();            

            QMap<int, QVariantMap> monitorsByIdMap;
            for (auto it = monitorsMap.constBegin(); it != monitorsMap.constEnd(); ++it) {
                QVariantMap monData = it.value();
                int monitorId = monData["id"].toInt();
                monitorsByIdMap[monitorId] = monData;
            }

            QMap<int, QVariantList> workspaceAppsMap;
            QMap<int, int> workspaceToMonitorIdMap;

            for (const QJsonValue &value : clientsArray) {
                QJsonObject clientObj = value.toObject();
                int workspaceId = clientObj["workspace"].toObject()["id"].toInt();
                
                int targetMonitorId = -1;
                
                if (clientObj["monitor"].isDouble()) {
                    targetMonitorId = clientObj["monitor"].toInt();
                } else {
                    QString monitorStringName = clientObj["monitor"].toString();
                    if (monitorsMap.contains(monitorStringName)) {
                        targetMonitorId = monitorsMap[monitorStringName]["id"].toInt();
                    }
                }

                if (targetMonitorId != -1) {
                    workspaceToMonitorIdMap[workspaceId] = targetMonitorId;
                }

                QVariantMap appData;
                appData["address"] = clientObj["address"].toString();
                appData["class"] = clientObj["class"].toString();
                appData["title"] = clientObj["title"].toString();
                
                QJsonArray atArray = clientObj["at"].toArray();
                appData["x"] = atArray.size() > 0 ? atArray.at(0).toInt() : 0;
                appData["y"] = atArray.size() > 1 ? atArray.at(1).toInt() : 0;

                QJsonArray sizeArray = clientObj["size"].toArray();
                appData["w"] = sizeArray.size() > 0 ? sizeArray.at(0).toInt() : 0;
                appData["h"] = sizeArray.size() > 1 ? sizeArray.at(1).toInt() : 0;

                workspaceAppsMap[workspaceId].append(appData);
            }

            QVariantList workspacesData;
            for (auto it = workspaceAppsMap.constBegin(); it != workspaceAppsMap.constEnd(); ++it) {
                int wsId = it.key();
                
                int finalMonitorId = workspaceToMonitorIdMap.value(wsId, (wsId <= 10) ? 0 : 1);
                
                QVariantMap finalMonitorData = monitorsByIdMap.value(finalMonitorId, QVariantMap());

                if (finalMonitorData.isEmpty() && !monitorsByIdMap.isEmpty()) {
                    finalMonitorData = monitorsByIdMap.constBegin().value();
                }

                QVariantMap workspaceNode;
                workspaceNode["id"] = wsId;
                workspaceNode["apps"] = it.value();
                workspaceNode["monitor"] = finalMonitorData;
                
                workspacesData.append(workspaceNode);
            }

            callback(workspacesData);
        };


        QObject::connect(clientSocket, &QLocalSocket::connected, [clientSocket]() {
            clientSocket->write("j/clients");
            clientSocket->flush();
        });
        QObject::connect(clientSocket, &QLocalSocket::readyRead, [clientSocket, clientBuffer]() {
            clientBuffer->append(clientSocket->readAll());
        });
        QObject::connect(clientSocket, &QLocalSocket::disconnected, [processData]() {
            processData();
        });
        QObject::connect(clientSocket, &QLocalSocket::errorOccurred, [processData](QLocalSocket::LocalSocketError) {
            processData();
        });
        QTimer::singleShot(1000, clientSocket, [processData]() {
            processData();
        });

        clientSocket->connectToServer(socketPath);
    };

    QObject::connect(monitorSocket, &QLocalSocket::connected, [monitorSocket]() {
        monitorSocket->write("j/monitors");
        monitorSocket->flush();
    });
    QObject::connect(monitorSocket, &QLocalSocket::readyRead, [monitorSocket, monitorBuffer]() {
        monitorBuffer->append(monitorSocket->readAll());
    });
    QObject::connect(monitorSocket, &QLocalSocket::disconnected, [monitorSocket, requestClients]() {
        monitorSocket->deleteLater();
        requestClients();
    });
    QObject::connect(monitorSocket, &QLocalSocket::errorOccurred, [monitorSocket, requestClients](QLocalSocket::LocalSocketError) {
        monitorSocket->deleteLater();
        requestClients();
    });
    QTimer::singleShot(1000, monitorSocket, [monitorSocket, requestClients]() {
        monitorSocket->deleteLater();
        requestClients();
    });

    monitorSocket->connectToServer(socketPath);
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
                "changefloatingmode>>", "monitoradded>>", "monitorremoved>>"
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

} // namespace jozet
