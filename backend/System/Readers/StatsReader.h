#pragma once
#include <QVariantMap>
#include <QVariantList>
#include <QString>

namespace jozet {
    class StatsReader {
    public:
        QVariantMap readStats();
    private:
        QString getUptime();
        QVariantList getMostUsedApps();
    };
}