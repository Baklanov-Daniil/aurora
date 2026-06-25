#include "resultimageprovider.h"

ResultImageProvider::ResultImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage ResultImageProvider::requestImage(const QString &id,
                                         QSize *size,
                                         const QSize &requestedSize)
{
    Q_UNUSED(id)

    QMutexLocker lock(&m_mutex);
    QImage result = m_image;

    if (size)
        *size = result.size();

    if (!requestedSize.isEmpty() && !result.isNull()) {
        return result.scaled(requestedSize,
                             Qt::KeepAspectRatio,
                             Qt::SmoothTransformation);
    }
    return result;
}

void ResultImageProvider::setImage(const QImage &image)
{
    QMutexLocker lock(&m_mutex);
    m_image = image;
}
