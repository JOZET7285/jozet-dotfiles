#pragma once
#include <QString>

namespace jozet {
    class DiskReader {
    public:
        double readUsagePercent(const QString &path);
    };
}