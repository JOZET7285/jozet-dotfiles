#pragma once

#include <QVariantList>
#include <QVariantMap>
#include <QString>

namespace jozet {

class HyprlandReader {
public:

    void readWorkspacesAsync(std::function<void(QVariantList)> callback);
};

}