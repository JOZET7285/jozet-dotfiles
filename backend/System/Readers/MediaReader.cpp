#include "Readers/MediaReader.h"
#include <QTimer>

namespace jozet {

static const QString kSeparator = QStringLiteral("\x1f");

MediaReader::MediaReader(QObject *parent) : QObject(parent) {
    m_positionTimer = new QTimer(this);
    m_positionTimer->setInterval(1000);
    connect(m_positionTimer, &QTimer::timeout, this, &MediaReader::pollPosition);
    startFollowing();
}

void MediaReader::startFollowing() {
    m_process = new QProcess(this);

    const QString format =
        "{{title}}" + kSeparator +
        "{{artist}}" + kSeparator +
        "{{album}}" + kSeparator +
        "{{mpris:artUrl}}" + kSeparator +
        "{{mpris:length}}" + kSeparator +
        "{{status}}";

    connect(m_process, &QProcess::readyReadStandardOutput, this, [this]() {
        m_buffer += m_process->readAllStandardOutput();

        int newlineIndex;
        while ((newlineIndex = m_buffer.indexOf('\n')) != -1) {
            QByteArray lineBytes = m_buffer.left(newlineIndex);
            m_buffer.remove(0, newlineIndex + 1);
            handleLine(QString::fromUtf8(lineBytes));
        }
    });

    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int, QProcess::ExitStatus) {
        m_hasPlayer = false;
        m_playing = false;
        m_positionTimer->stop();
        m_positionUs = 0;
        emit mediaChanged();
        emit positionChanged();
        QTimer::singleShot(2000, this, &MediaReader::startFollowing);
    });

    m_process->start("playerctl", {"-F", "metadata", "--format", format});
}

void MediaReader::handleLine(const QString &line) {
    QStringList parts = line.split(kSeparator);
    if (parts.size() < 6) return;

    const QString newTitle = parts[0];
    const QString newArtist = parts[1];
    const QString newAlbum = parts[2];
    const QString newArtUrl = parts[3];
    const qint64 newLength = parts[4].toLongLong();
    const bool newPlaying = parts[5].trimmed() == "Playing";

    const bool trackChanged = newTitle != m_title || newArtist != m_artist ||
        newAlbum != m_album || newArtUrl != m_artUrl || newLength != m_length;

    if (!trackChanged && newPlaying == m_playing && m_hasPlayer) {
        return;
    }

    m_title = newTitle;
    m_artist = newArtist;
    m_album = newAlbum;
    m_artUrl = newArtUrl;
    m_length = newLength;
    m_playing = newPlaying;
    m_hasPlayer = true;

    if (trackChanged) {
        m_positionUs = 0;
        emit positionChanged();
    }

    if (m_playing) {
        m_positionTimer->start();
    } else {
        m_positionTimer->stop();
    }

    pollPosition();

    emit mediaChanged();
}

void MediaReader::playPause() {
    QProcess::startDetached("playerctl", {"play-pause"});
}

void MediaReader::next() {
    QProcess::startDetached("playerctl", {"next"});
}

void MediaReader::previous() {
    QProcess::startDetached("playerctl", {"previous"});
}

void MediaReader::pollPosition() {
    QProcess *proc = new QProcess(this);
    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this, proc](int, QProcess::ExitStatus) {
        QString output = QString::fromUtf8(proc->readAllStandardOutput()).trimmed();
        bool ok;
        double pos = output.toDouble(&ok);
        if (ok) {
            qint64 newPos = static_cast<qint64>(pos * 1000000);
            if (newPos != m_positionUs) {
                m_positionUs = newPos;
                emit positionChanged();
            }
        }
        proc->deleteLater();
    });
    proc->start("playerctl", {"position"});
}

}