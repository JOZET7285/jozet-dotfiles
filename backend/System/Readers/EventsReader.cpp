#include "Readers/EventsReader.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDir>
#include <QThread>

namespace jozet {
    QVariantList EventsReader::readEvents() {
        QVariantList events;
        QFile file(QDir::homePath() + "/.config/quickshell/Assets/Events.json");
        
        if (file.open(QIODevice::ReadOnly)) {
            QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
            if (doc.isArray()) {
                events = doc.array().toVariantList();
            }
        }
        return events;
    }
    void EventsReader::writeEvents(const QVariantList &events) {
        QThread *workerThread = QThread::create([events]() {
            QFile file(QDir::homePath() + "/.config/quickshell/Assets/Events.json");
            if (file.open(QIODevice::WriteOnly)) {
                QJsonArray array = QJsonArray::fromVariantList(events);
                QJsonDocument doc(array);
                file.write(doc.toJson());
            }
        });
        QObject::connect(workerThread, &QThread::finished, workerThread, &QObject::deleteLater);
        workerThread->start();
    }
}