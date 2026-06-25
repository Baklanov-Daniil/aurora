#ifndef RESULTIMAGEPROVIDER_H
#define RESULTIMAGEPROVIDER_H

#pragma once

#include <QQuickImageProvider>
#include <QImage>
#include <QMutex>

class ResultImageProvider : public QQuickImageProvider
{
public:
    ResultImageProvider();

    QImage requestImage(const QString &id, QSize *size,
                        const QSize &requestedSize) override;

    void setImage(const QImage &image);

private:
    QMutex m_mutex;
    QImage m_image;
};

#endif // RESULTIMAGEPROVIDER_H

