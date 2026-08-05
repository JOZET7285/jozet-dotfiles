#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <QTimer>

namespace jozet {

class MediaReader : public QObject {
    Q_OBJECT
    Q_PROPERTY(qint64 positionUs READ positionUs NOTIFY positionChanged)
    Q_PROPERTY(qint64 lengthUs READ lengthMicroseconds NOTIFY mediaChanged)
public:
    explicit MediaReader(QObject *parent = nullptr);

    QString title() const { return m_title; }
    QString artist() const { return m_artist; }
    QString album() const { return m_album; }
    QString artUrl() const { return m_artUrl; }
    qint64 lengthMicroseconds() const { return m_length; }
    qint64 positionUs() const { return m_positionUs; }
    bool isPlaying() const { return m_playing; }
    bool hasPlayer() const { return m_hasPlayer; }

    void playPause();
    void next();
    void previous();

signals:
    void mediaChanged();
    void positionChanged();

private:
    void startFollowing();
    void handleLine(const QString &line);
    void pollPosition();

    QProcess *m_process = nullptr;
    QByteArray m_buffer;

    QString m_title;
    QString m_artist;
    QString m_album;
    QString m_artUrl;
    qint64 m_length = 0;
    qint64 m_positionUs = 0;
    bool m_playing = false;
    bool m_hasPlayer = false;

    QTimer *m_positionTimer;
};

}