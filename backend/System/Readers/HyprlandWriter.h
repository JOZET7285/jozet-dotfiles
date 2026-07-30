#pragma once
#include <QObject>
#include <QVariantMap>
#include <QProcess>
#include <QFile>
#include <QDir>

namespace jozet {

class SettingsReader;

class HyprlandWriter : public QObject {
    Q_OBJECT
public:
    explicit HyprlandWriter(SettingsReader *reader, QObject *parent = nullptr);

public slots:
    void applyAll();
    void applySetting(const QString &key, const QVariant &value);

private:
    void runHyprctl(const QString &keyword, const QString &value);
    void restartHypridle();
    QString luaDataPath() const;
    void writeLuaDataFile();

    SettingsReader *m_reader;
};

}
