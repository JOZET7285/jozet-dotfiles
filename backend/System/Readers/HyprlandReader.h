#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <functional>

class QLocalSocket;

namespace jozet {

class HyprlandReader : public QObject {
    Q_OBJECT
public:
    explicit HyprlandReader(QObject *parent = nullptr);

    void readWorkspacesAsync(std::function<void(QVariantList)> callback);

signals:
    void workspacesShouldRefresh();

private:
    void connectEventSocket();

    QLocalSocket *m_eventSocket = nullptr;
    QByteArray m_eventBuffer;
};

}