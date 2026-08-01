#pragma once

#include <QObject>
#include <QVariantList>
#include <QString>

namespace jozet {

class CursorReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList availableCursors READ availableCursors NOTIFY availableCursorsChanged)

public:
    explicit CursorReader(QObject *parent = nullptr);
    QVariantList availableCursors() const;
    Q_INVOKABLE void refreshCursors();

signals:
    void availableCursorsChanged();

private:
    QVariantList m_availableCursors;
};

} // namespace jozet