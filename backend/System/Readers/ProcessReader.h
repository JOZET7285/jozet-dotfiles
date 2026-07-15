#pragma once
#include <QVariantList>

namespace jozet {
    class ProcessReader {
    public:
        QVariantList readTopRamProcesses(int limit = 5);
        QVariantList readTopCpuProcesses(int limit = 5);
    };
}