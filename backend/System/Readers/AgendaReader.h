#pragma once
#include <QVariantList>

namespace jozet {
    class AgendaReader {
    public:
        QVariantList readAgenda();
        void writeAgenda(const QVariantList &agenda);
    };
}