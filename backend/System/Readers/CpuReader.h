#pragma once

namespace jozet {
    class CpuReader {
    public:
        int readUsagePercent();

    private:
        long m_prevIdle = 0;
        long m_prevTotal = 0;
    };
}