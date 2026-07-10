#pragma once
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QProcess>
#include <vector>
#include <QTimer>
#include <QObject>
#include <functional>

namespace jozet {
    struct PlaybackDevice {
        QString name;
        QString description;
        uint32_t index;
        uint32_t volume;
        bool isDefault;
        bool isMuted;
    };

    struct InputDevice {
        QString name;
        QString description;
        uint32_t index;
        uint32_t volume;
        bool isDefault;
        bool isMuted;
    };

    struct PlayingApp {
        QString name;
        QString media;
        QString icon;
        uint32_t pid;
        uint32_t volume;
        bool isMuted;
    };

    class VolumeReader : public QObject {
        Q_OBJECT
    public:
        explicit VolumeReader(QObject *parent = nullptr);
        ~VolumeReader();
        
        void updateVolumeStatus();
        void startEventListener(std::function<void()> onVolumeEvent);
        
        QVariantMap playbackDeviceInfo() const;
        QVariantMap inputDeviceInfo() const;
        Q_INVOKABLE QVariantList playingApplications() const;
        
        Q_INVOKABLE void setPlaybackVolume(int volume);
        Q_INVOKABLE void setInputVolume(int volume);
        Q_INVOKABLE void setApplicationVolume(uint32_t pid, int volume);
        Q_INVOKABLE void setPlaybackMuted(bool muted);
        Q_INVOKABLE void setInputMuted(bool muted);
        Q_INVOKABLE void setDefaultPlaybackDevice(uint32_t index);
        Q_INVOKABLE void setDefaultInputDevice(uint32_t index);
        Q_INVOKABLE void setApplicationMuted(uint32_t pid, bool muted);

    signals:
        void dataUpdated();

    private:
        void fetchDefaults();
        void fetchSinks();
        void fetchSources();
        void fetchSinkInputs();
        
        void runPactlAsync(const QStringList &args, std::function<void(const QByteArray &)> callback);
        QString getApplicationIcon(const QString &appName);

        QProcess *m_subscribeProcess = nullptr;
        QTimer *m_updateTimer = nullptr;

        QString m_defaultSinkName;
        QString m_defaultSourceName;

        PlaybackDevice m_defaultPlayback;
        InputDevice m_defaultInput;
        std::vector<PlaybackDevice> m_playbackDevices;
        std::vector<InputDevice> m_inputDevices;
        std::vector<PlayingApp> m_playingApps;
    };
}