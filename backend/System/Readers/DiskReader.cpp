#include "Readers/DiskReader.h"
#include <QStorageInfo>
#include <cmath>

namespace jozet {

double DiskReader::readUsagePercent(const QString &path) {
    QStorageInfo storage(path);
    if (!storage.isValid() || !storage.isReady())
        return 0.0;

    qint64 total = storage.bytesTotal();
    qint64 available = storage.bytesAvailable();
    qint64 used = total - available;

    double percent = (double)used / total * 100.0;
    return std::round(percent * 10.0) / 10.0;
}

}