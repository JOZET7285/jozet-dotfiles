#include "Readers/FastfetchReader.h"
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

namespace jozet {

FastfetchReader::FastfetchReader(QObject *parent) : QObject(parent) {
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &FastfetchReader::fetch);
    m_timer->start(30000);

    fetch();
}

QVariantMap FastfetchReader::systemInfo() const {
    return m_info;
}

void FastfetchReader::refresh() {
    fetch();
}

void FastfetchReader::fetch() {
    QProcess process;
    process.start("fastfetch", {"--format", "json"});
    process.waitForFinished(5000);

    if (process.exitCode() != 0)
        return;

    QJsonDocument doc = QJsonDocument::fromJson(process.readAllStandardOutput());
    if (doc.isNull() || !doc.isArray())
        return;

    QJsonArray modules = doc.array();
    QVariantMap info;

    for (const QJsonValue &val : modules) {
        QJsonObject obj = val.toObject();
        QString type = obj["type"].toString();
        QJsonObject result = obj["result"].toObject();

        if (type == "Title") {
            info["hostname"] = result["hostName"].toString();
            info["username"] = result["userName"].toString();
            info["shell"] = result["userShell"].toString();
        }
        else if (type == "OS") {
            info["os"] = result["prettyName"].toString();
        }
        else if (type == "Kernel") {
            info["kernel"] = result["release"].toString();
            info["arch"] = result["architecture"].toString();
        }
        else if (type == "WM") {
            info["wm"] = result["prettyName"].toString() + " " + result["version"].toString();
            info["protocol"] = result["protocolName"].toString();
        }
        else if (type == "CPU") {
            info["cpu"] = result["cpu"].toString();
            QJsonObject freq = result["frequency"].toObject();
            info["cpuFreq"] = QString::number(freq["max"].toInt()) + " MHz";
            QJsonObject cores = result["cores"].toObject();
            info["cpuCores"] = QString::number(cores["physical"].toInt()) + "C / " +
                               QString::number(cores["logical"].toInt()) + "T";
        }
        else if (type == "GPU") {
            info["gpu"] = result["name"].toString();
            info["gpuVendor"] = result["vendor"].toString();
            info["gpuDriver"] = result["driver"].toString();
            info["gpuType"] = result["type"].toString();
        }
        else if (type == "Memory") {
            qint64 total = result["total"].toVariant().toLongLong();
            qint64 used = result["used"].toVariant().toLongLong();
            info["ramTotal"] = QString::number(total / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
            info["ramUsed"] = QString::number(used / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
            info["ramPercent"] = total > 0 ? QString::number(used * 100.0 / total, 'f', 1) + "%" : "0%";
        }
        else if (type == "Disk") {
            QJsonObject bytes = result["bytes"].toObject();
            QString mountpoint = result["mountpoint"].toString();
            qint64 total = bytes["total"].toVariant().toLongLong();
            qint64 used = bytes["used"].toVariant().toLongLong();

            if (mountpoint == "/") {
                info["diskRootTotal"] = QString::number(total / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
                info["diskRootUsed"] = QString::number(used / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
                info["diskRootFs"] = result["filesystem"].toString();
            } else if (mountpoint == "/home") {
                info["diskHomeTotal"] = QString::number(total / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
                info["diskHomeUsed"] = QString::number(used / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
                info["diskHomeFs"] = result["filesystem"].toString();
            }
        }
        else if (type == "Battery") {
            info["batteryCapacity"] = result["capacity"].toDouble();
            info["batteryManufacturer"] = result["manufacturer"].toString();
            info["batteryModel"] = result["modelName"].toString();
            info["batteryTechnology"] = result["technology"].toString();
            QJsonArray status = result["status"].toArray();
            info["batteryStatus"] = status.isEmpty() ? "N/A" : status[0].toString();
        }
    }

    if (m_info != info) {
        m_info = info;
        emit systemInfoChanged();
    }
}

}
