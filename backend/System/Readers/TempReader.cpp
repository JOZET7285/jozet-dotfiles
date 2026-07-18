#include "Readers/TempReader.h"
#include <QDir>
#include <QFile>
#include <QVariantMap>

namespace jozet {

TempReader::TempReader() {
    initSensors();
}

void TempReader::initSensors() {
    QDir hwmonDir("/sys/class/hwmon");
    
    for (const QString &dirName : hwmonDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QString path = hwmonDir.absoluteFilePath(dirName);
        
        QFile nameFile(path + "/name");
        QString name = "Desconocido";
        if (nameFile.open(QIODevice::ReadOnly)) {
            name = QString::fromUtf8(nameFile.readAll()).trimmed();
            nameFile.close();
        }

        QDir sensorDir(path);
        QStringList tempFiles = sensorDir.entryList({"temp*_input"}, QDir::Files);
        
        if (!tempFiles.isEmpty()) {
            CachedSensor sensor;
            sensor.name = name;
            for (const QString &tempFile : tempFiles) {
                sensor.tempInputPaths.append(path + "/" + tempFile);
            }
            m_cachedSensors.append(sensor);
        }
    }
}

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

    for (const CachedSensor &cachedSensor : std::as_const(m_cachedSensors)) {
        int highestTempInDir = 0;
        bool found = false;

        for (const QString &tempFilePath : cachedSensor.tempInputPaths) {
            QFile file(tempFilePath);
            if (file.open(QIODevice::ReadOnly)) {
                int temp = QString::fromUtf8(file.readAll()).trimmed().toInt() / 1000;
                if (temp > highestTempInDir) {
                    highestTempInDir = temp;
                    found = true;
                }
                file.close();
            }
        }

        if (found && highestTempInDir > 0) {
            QVariantMap sensorData;
            sensorData["name"] = cachedSensor.name;
            sensorData["temperature"] = highestTempInDir;
            sensors.append(sensorData);
        }
    }
    return sensors;
}

} // namespace jozet