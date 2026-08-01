#pragma once
#include <QObject>
#include <QVariantMap>
#include <QProcess>
#include <QFile>
#include <QDir>

namespace jozet {

class SettingsReader;
class MatugenReader;

class HyprlandWriter : public QObject {
    Q_OBJECT
public:
    explicit HyprlandWriter(SettingsReader *reader, MatugenReader *matugen = nullptr, QObject *parent = nullptr);

public slots:
    void applyAll();
    void applyBorderColors();
    void applySetting(const QString &key, const QVariant &value);

private:
    QString accentColor() const;
    QString toHyprColor(const QString &hex, const QString &alpha = "ff") const;
    void applyCursorTheme();
    void runHyprctl(const QString &keyword, const QString &value);
    void restartHypridle();
    QString luaDataPath() const;
    void writeLuaDataFile();

    SettingsReader *m_reader;
    MatugenReader *m_matugen;
};

}
