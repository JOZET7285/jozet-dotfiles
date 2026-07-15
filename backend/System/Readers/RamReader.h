#pragma once

namespace jozet {
    
    struct RamData {
        long totalMB = 0;
        long usedMB = 0;
        int usagePercent = 0;
        
        long swapTotalMB = 0;
        long swapUsedMB = 0;
        int swapUsagePercent = 0;
    };

    class RamReader {
    public:
        RamData readData();
    };
}