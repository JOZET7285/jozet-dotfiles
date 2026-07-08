#include "Readers/TempReader.h"
#include <QFile>

namespace jozet {

int TempReader::readCpuTemperature() {
    QFile file("/sys/class/thermal/thermal_zone0/temp");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;

    QString content = file.readAll();
    file.close();

    return content.toInt() / 1000;
}

}