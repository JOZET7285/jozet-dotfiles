#pragma once

#include <QVariantList>
#include <QVariantMap>
#include <QString>

namespace jozet {

class HyprlandReader {
public:
    QVariantList readWorkspaces();
    void moveWindowToWorkspace(const QString &windowAddress, int workspaceId);
};

}