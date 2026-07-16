#include "Readers/AgendaReader.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDir>

namespace jozet {
    QVariantList AgendaReader::readAgenda() {
        QVariantList agenda;
        QFile file(QDir::homePath() + "/.config/quickshell/Assets/Agenda.json");
        
        if (file.open(QIODevice::ReadOnly)) {
            QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
            if (doc.isArray()) {
                agenda = doc.array().toVariantList();
            }
        }
        return agenda;
    }

    void AgendaReader::writeAgenda(const QVariantList &agenda) {
        QFile file(QDir::homePath() + "/.config/quickshell/Assets/Agenda.json");
        
        if (file.open(QIODevice::WriteOnly)) {
            QJsonArray array = QJsonArray::fromVariantList(agenda);
            QJsonDocument doc(array);
            file.write(doc.toJson());
        }
    }
}