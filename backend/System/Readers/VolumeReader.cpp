#include "Readers/VolumeReader.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTimer>
#include <QDebug>
#include <QProcessEnvironment>

namespace jozet {

VolumeReader::VolumeReader(QObject *parent) : QObject(parent) {
    m_updateTimer = new QTimer(this);
    m_updateTimer->setSingleShot(true);
    m_updateTimer->setInterval(150);
    connect(m_updateTimer, &QTimer::timeout, this, &VolumeReader::updateVolumeStatus);

    updateVolumeStatus();
}

VolumeReader::~VolumeReader() {
    if (m_subscribeProcess) {
        m_subscribeProcess->kill();
        m_subscribeProcess->deleteLater();
    }
}

void VolumeReader::runPactlAsync(const QStringList &args, std::function<void(const QByteArray &)> callback) {
    QProcess *process = new QProcess(this);

    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL", "C");
    env.insert("LANG", "C");
    process->setProcessEnvironment(env);
    
    connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), 
            [process, callback](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            callback(process->readAllStandardOutput());
        }
        process->deleteLater();
    });
    process->start("pactl", args);
}

void VolumeReader::startEventListener(std::function<void()> onVolumeEvent) {
    m_subscribeProcess = new QProcess(this);

    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL", "C");
    env.insert("LANG", "C");
    m_subscribeProcess->setProcessEnvironment(env);
    
    m_subscribeProcess->start("pactl", {"subscribe"});

    connect(m_subscribeProcess, &QProcess::readyReadStandardOutput, [this, onVolumeEvent]() {
        QString output = m_subscribeProcess->readAllStandardOutput();
        if (output.contains("sink") || output.contains("source")) {
            m_updateTimer->start();
            onVolumeEvent();
        }
    });
}

void VolumeReader::updateVolumeStatus() {
    runPactlAsync({"info"}, [this](const QByteArray &data) {
        QString output = QString(data);
        QStringList lines = output.split('\n');
        for (const QString &line : lines) {
            if (line.startsWith("Default Sink: ")) {
                m_defaultSinkName = line.mid(14).trimmed();
            } else if (line.startsWith("Default Source: ")) {
                m_defaultSourceName = line.mid(16).trimmed();
            }
        }
        fetchSinks();
        fetchSources();
        fetchSinkInputs();
    });
}

void VolumeReader::fetchSinks() {
    runPactlAsync({"--format=json", "list", "sinks"}, [this](const QByteArray &data) {
        m_playbackDevices.clear();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        for (const QJsonValue &val : doc.array()) {
            QJsonObject obj = val.toObject();
            PlaybackDevice device;
            device.name = obj["name"].toString();
            device.description = obj["description"].toString();
            device.index = (uint32_t)obj["index"].toInt();
            device.isMuted = obj["mute"].toBool();
            device.isDefault = (device.name == m_defaultSinkName);

            QJsonObject volumeObj = obj["volume"].toObject();
            if (!volumeObj.isEmpty()) {
                device.volume = volumeObj.begin().value().toObject()["value_percent"].toString().remove('%').toInt();
            } else {
                device.volume = 0;
            }

            m_playbackDevices.push_back(device);
            if (device.isDefault) m_defaultPlayback = device;
        }
        emit dataUpdated();
    });
}

void VolumeReader::fetchSources() {
    runPactlAsync({"--format=json", "list", "sources"}, [this](const QByteArray &data) {
        m_inputDevices.clear();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        for (const QJsonValue &val : doc.array()) {
            QJsonObject obj = val.toObject();
            if (obj["name"].toString().endsWith(".monitor")) continue;

            InputDevice device;
            device.name = obj["name"].toString();
            device.description = obj["description"].toString();
            device.index = (uint32_t)obj["index"].toInt();
            device.isMuted = obj["mute"].toBool();
            device.isDefault = (device.name == m_defaultSourceName);

            QJsonObject volumeObj = obj["volume"].toObject();
            if (!volumeObj.isEmpty()) {
                device.volume = volumeObj.begin().value().toObject()["value_percent"].toString().remove('%').toInt();
            } else {
                device.volume = 0;
            }

            m_inputDevices.push_back(device);
            if (device.isDefault) m_defaultInput = device;
        }
        emit dataUpdated();
    });
}

void VolumeReader::fetchSinkInputs() {
    runPactlAsync({"--format=json", "list", "sink-inputs"}, [this](const QByteArray &data) {
        m_playingApps.clear();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        for (const QJsonValue &val : doc.array()) {
            QJsonObject obj = val.toObject();
            QJsonObject props = obj["properties"].toObject();
            QString appName = props["application.name"].toString();
            
            if (appName.isEmpty()) continue;

            PlayingApp app;
            app.name = appName;
            app.media = props["media.name"].toString();
            app.icon = getApplicationIcon(appName);
            app.pid = (uint32_t)props["application.process.id"].toString().toUInt();
            app.isMuted = obj["mute"].toBool();

            QJsonObject volumeObj = obj["volume"].toObject();
            if (!volumeObj.isEmpty()) {
                app.volume = volumeObj.begin().value().toObject()["value_percent"].toString().remove('%').toInt();
            } else {
                app.volume = 0;
            }

            m_playingApps.push_back(app);
        }
        emit dataUpdated();
    });
}

QString VolumeReader::getApplicationIcon(const QString &appName) {
    if (appName.contains("firefox", Qt::CaseInsensitive)) return "\uf269";
    if (appName.contains("chrome", Qt::CaseInsensitive) || appName.contains("brave", Qt::CaseInsensitive)) return "\uf268";
    if (appName.contains("spotify", Qt::CaseInsensitive)) return "\uf1bc";
    if (appName.contains("vlc", Qt::CaseInsensitive) || appName.contains("mpv", Qt::CaseInsensitive)) return "\uf04b";
    if (appName.contains("discord", Qt::CaseInsensitive) || appName.contains("vesktop", Qt::CaseInsensitive)) return "\uf392";
    return "\uf028";
}

QVariantMap VolumeReader::playbackDeviceInfo() const {
    return {
        {"name", m_defaultPlayback.name},
        {"description", m_defaultPlayback.description},
        {"volume", m_defaultPlayback.volume},
        {"isMuted", m_defaultPlayback.isMuted},
        {"index", (int)m_defaultPlayback.index}
    };
}

QVariantMap VolumeReader::inputDeviceInfo() const {
    return {
        {"name", m_defaultInput.name},
        {"description", m_defaultInput.description},
        {"volume", m_defaultInput.volume},
        {"isMuted", m_defaultInput.isMuted},
        {"index", (int)m_defaultInput.index}
    };
}

QVariantList VolumeReader::playingApplications() const {
    QVariantList list;
    for (const auto &app : m_playingApps) {
        list.append(QVariantMap{
            {"name", app.name},
            {"media", app.media},
            {"icon", app.icon},
            {"volume", app.volume},
            {"isMuted", app.isMuted},
            {"pid", (int)app.pid}
        });
    }
    return list;
}

void VolumeReader::setPlaybackVolume(int volume) {
    volume = std::clamp(volume, 0, 150);
    QProcess::startDetached("pactl", {"set-sink-volume", "@DEFAULT_SINK@", QString::number(volume) + "%"});
}
void VolumeReader::setInputVolume(int volume) {
    volume = std::clamp(volume, 0, 100); 
    QProcess::startDetached("pactl", {"set-source-volume", "@DEFAULT_SOURCE@", QString::number(volume) + "%"});
}
void VolumeReader::setApplicationVolume(uint32_t pid, int volume) {
    volume = std::clamp(volume, 0, 150);
    QProcess::startDetached("pactl", {"set-sink-input-volume", QString::number(pid), QString::number(volume) + "%"});
}
void VolumeReader::setPlaybackMuted(bool muted) {
    QProcess::startDetached("pactl", {"set-sink-mute", "@DEFAULT_SINK@", muted ? "1" : "0"});
}

void VolumeReader::setInputMuted(bool muted) {
    QProcess::startDetached("pactl", {"set-source-mute", "@DEFAULT_SOURCE@", muted ? "1" : "0"});
}
void VolumeReader::setDefaultPlaybackDevice(uint32_t index) {
    QProcess::startDetached("pactl", {"set-default-sink", QString::number(index)});
}

void VolumeReader::setDefaultInputDevice(uint32_t index) {
    QProcess::startDetached("pactl", {"set-default-source", QString::number(index)});
}

void VolumeReader::setApplicationMuted(uint32_t pid, bool muted) {
    QProcess::startDetached("pactl", {"set-sink-input-mute", QString::number(pid), muted ? "1" : "0"});
}

}