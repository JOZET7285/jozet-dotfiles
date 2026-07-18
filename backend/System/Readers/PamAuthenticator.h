#pragma once
#include <QObject>
#include <QString>

namespace jozet {

class PamAuthenticator : public QObject {
    Q_OBJECT
public:
    explicit PamAuthenticator(QObject *parent = nullptr);

    Q_INVOKABLE bool authenticate(const QString &username, const QString &password);
};

}