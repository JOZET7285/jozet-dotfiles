#pragma once
#include <QVariantList>
#include <QString>
#include <QStringList>
#include <QList>

namespace jozet {
    
    // Estructura para guardar las rutas en memoria
    struct CachedSensor {
        QString name;
        QStringList tempInputPaths;
    };

    class TempReader {
    public:
        TempReader(); 
        
        int readMaxTemperature();
        QVariantList readAllSensors();

    private:
        void initSensors();
        QList<CachedSensor> m_cachedSensors;
    };

}