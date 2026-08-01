#include "CursorReader.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QSet>

namespace jozet {

static const quint32 XCURSOR_IMAGE = 0xfffd0002;

static quint32 rdU32(const QByteArray &data, quint32 offset)
{
    if (offset + 4 > static_cast<quint32>(data.size()))
        return 0;
    quint32 v;
    memcpy(&v, data.constData() + offset, 4);
    return v;
}

static QImage loadCursorImage(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return QImage();

    QByteArray data = file.readAll();
    if (data.startsWith("\x89PNG\r\n\x1a\n"))
        return QImage::fromData(data);

    if (data.size() < 16 || data.left(4) != QByteArray("Xcur", 4))
        return QImage();

    const quint32 headerSize = rdU32(data, 4);
    const quint32 ntoc = rdU32(data, 12);

    QImage best;
    for (quint32 i = 0; i < ntoc; ++i) {
        const quint32 tocOff = headerSize + i * 12;
        if (tocOff + 12 > static_cast<quint32>(data.size()))
            break;

        if (rdU32(data, tocOff) != XCURSOR_IMAGE)
            continue;

        const quint32 pos = rdU32(data, tocOff + 8);
        if (pos == 0 || pos + 36 > static_cast<quint32>(data.size()))
            continue;

        const int pngStart = data.indexOf("\x89PNG\r\n\x1a\n", pos + 12);
        if (pngStart != -1) {
            QImage png = QImage::fromData(data.mid(pngStart));
            if (!png.isNull()) {
                if (png.width() * png.height() > best.width() * best.height())
                    best = png;
                continue;
            }
        }

        const quint32 headerLength = rdU32(data, pos);
        const quint32 width = rdU32(data, pos + 16);
        const quint32 height = rdU32(data, pos + 20);
        if (width == 0 || height == 0 || width > 256 || height > 256)
            continue;

        const quint32 pixelBytes = width * height * 4;
        const quint32 pixelsOff = pos + headerLength;
        if (pixelsOff + pixelBytes > static_cast<quint32>(data.size()))
            continue;

        QImage img(width, height, QImage::Format_ARGB32);
        memcpy(img.bits(), data.constData() + pixelsOff, pixelBytes);
        if (img.width() * img.height() > best.width() * best.height())
            best = img;
    }

    return best;
}

static QString generatePreview(const QString &themePath, const QString &themeName)
{
    QDir cursorsDir(themePath + "/cursors");
    if (!cursorsDir.exists())
        return QString();

    const QStringList names = cursorsDir.entryList(QDir::Files | QDir::NoDotAndDotDot);
    if (names.isEmpty())
        return QString();

    QString preferred;
    if (names.contains("default")) preferred = "default";
    else if (names.contains("left_ptr")) preferred = "left_ptr";
    else preferred = names.first();

    QImage img = loadCursorImage(cursorsDir.filePath(preferred));
    if (img.isNull())
        return QString();

    if (img.width() > 48 || img.height() > 48)
        img = img.scaled(48, 48, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    QDir cacheDir(QDir::homePath() + "/.cache/jzt/cursors");
    cacheDir.mkpath(".");

    const QString outPath = cacheDir.filePath(themeName + ".png");
    return img.save(outPath, "PNG") ? outPath : QString();
}

CursorReader::CursorReader(QObject *parent) : QObject(parent)
{
    refreshCursors();
}

QVariantList CursorReader::availableCursors() const
{
    return m_availableCursors;
}

void CursorReader::refreshCursors()
{
    QVariantList cursors;
    QSet<QString> foundThemes;

    QStringList paths = {
        QDir::homePath() + "/.icons",
        QDir::homePath() + "/.local/share/icons",
        "/usr/share/icons"
    };

    for (const QString &path : paths) {
        QDir dir(path);
        if (!dir.exists()) continue;

        QFileInfoList entries = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QFileInfo &info : entries) {
            QString themeName = info.fileName();

            if (foundThemes.contains(themeName)) continue;

            QDir themeDir(info.absoluteFilePath());
            if (themeDir.exists("cursors")) {
                QVariantMap cursorData;
                cursorData["name"] = themeName;
                cursorData["path"] = info.absoluteFilePath();
                cursorData["preview"] = generatePreview(info.absoluteFilePath(), themeName);

                cursors.append(cursorData);
                foundThemes.insert(themeName);
            }
        }
    }

    if (m_availableCursors != cursors) {
        m_availableCursors = cursors;
        emit availableCursorsChanged();
    }
}

} // namespace jozet
