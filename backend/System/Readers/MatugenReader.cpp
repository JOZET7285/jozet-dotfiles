#include "Readers/MatugenReader.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject> 
#include <QDir>

namespace jozet {

MatugenReader::MatugenReader(QObject *parent) : QObject(parent) {
    m_filePath = QDir::homePath() + "/.local/share/jzt/matugen-colors.json";
    load();

    QDir().mkpath(QFileInfo(m_filePath).absolutePath());
    m_watcher.addPath(m_filePath);

    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, [this]() {
        load();
        emit colorsChanged();
        if (!m_watcher.files().contains(m_filePath))
            m_watcher.addPath(m_filePath);
    });
}

void MatugenReader::load() {
    QFile file(m_filePath);
    if (!file.open(QIODevice::ReadOnly)) return;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();
    if (doc.isObject()) m_colors = doc.object().toVariantMap();
}

}
