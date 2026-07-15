#pragma once

namespace jozet {
    class CpuReader {
    public:
        CpuReader(); 
        
        int readUsagePercent();
        int readCurrentFrequency();
        
    private:
        long m_previousTotal;
        long m_previousIdle;
    };
}