#pragma once
#include <QObject>
#include <QVariantMap>
#include <QString>

namespace jozet {

class SettingsReader : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantMap settings READ settings NOTIFY settingsChanged)

public:
    explicit SettingsReader(QObject *parent = nullptr);

    QVariantMap settings() const;

    Q_INVOKABLE QVariant get(const QString &key) const;
    Q_INVOKABLE void set(const QString &key, const QVariant &value);
    Q_INVOKABLE void reset();

signals:
    void settingsChanged();
    void settingChanged(const QString &key, const QVariant &value);

private:
    QString m_filePath;
    QVariantMap m_settings;

    void load();
    void save();
    void mergeDefaults(QVariantMap &target, const QVariantMap &defaults);
    bool setKey(QVariantMap &map, const QString &key, const QVariant &value);
};

}
