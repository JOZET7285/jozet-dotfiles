#include "HyprlandReader.h"
#include <QProcess>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

namespace jozet {

void HyprlandReader::readWorkspacesAsync(std::function<void(QVariantList)> callback) {
    auto *process = new QProcess();

    QObject::connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
        [process, callback](int, QProcess::ExitStatus) {
            QByteArray output = process->readAllStandardOutput();
            process->deleteLater();

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

    process->start("hyprctl", {"clients", "-j"});
}

}