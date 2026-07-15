#pragma once
#include <QVariantList>

namespace jozet {
    class TempReader {
    public:
        int readMaxTemperature();
        QVariantList readAllSensors();
    };
}