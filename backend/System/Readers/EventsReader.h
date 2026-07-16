#pragma once
#include <QVariantList>

namespace jozet {
    class EventsReader {
    public:
        QVariantList readEvents();
        void writeEvents(const QVariantList &events);
    };
}