#include "Readers/TempReader.h"
#include <QDir>
#include <QFile>
#include <QVariantMap>

namespace jozet {

int TempReader::readMaxTemperature() {
    int maxTemp = 0;
    QVariantList sensors = readAllSensors();
    
    for (const QVariant &sensorVar : sensors) {
        int temp = sensorVar.toMap()["temperature"].toInt();
        if (temp > maxTemp) {
            maxTemp = temp;
        }
    }
    return maxTemp;
}

QVariantList TempReader::readAllSensors() {
    QVariantList sensors;
    QDir hwmonDir("/sys/class/hwmon");

    for (const QString &dirName : hwmonDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QString path = hwmonDir.absoluteFilePath(dirName);
        
        QFile nameFile(path + "/name");
        QString name = "Desconocido";
        if (nameFile.open(QIODevice::ReadOnly)) {
            name = nameFile.readAll().trimmed();
            nameFile.close();
        }

        QDir sensorDir(path);
        QStringList tempFiles = sensorDir.entryList({"temp*_input"}, QDir::Files);
        
        int highestTempInDir = 0;
        bool found = false;
        for (const QString &tempFile : tempFiles) {
            QFile file(path + "/" + tempFile);
            if (file.open(QIODevice::ReadOnly)) {
                int temp = file.readAll().trimmed().toInt() / 1000;
                if (temp > highestTempInDir) {
                    highestTempInDir = temp;
                    found = true;
                }
                file.close();
            }
        }
        if (found && highestTempInDir > 0) {
            QVariantMap sensorData;
            sensorData["name"] = name;
            sensorData["temperature"] = highestTempInDir;
            sensors.append(sensorData);
        }
    }
    return sensors;
}

}