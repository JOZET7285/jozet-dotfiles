#pragma once
#include <QObject>
#include <QVariantMap>
#include <QFileSystemWatcher>

namespace jozet {
class MatugenReader : public QObject {
    Q_OBJECT
public:
    explicit MatugenReader(QObject *parent = nullptr);
    QVariantMap colors() const { return m_colors; }

signals:
    void colorsChanged();

private:
    QString m_filePath;
    QVariantMap m_colors;
    QFileSystemWatcher m_watcher;
    void load();
};
}