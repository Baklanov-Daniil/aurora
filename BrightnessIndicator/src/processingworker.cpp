#include "processingworker.h"

#include <QElapsedTimer>
#include <QImage>

ProcessingWorker::ProcessingWorker(QObject *parent)
    : QObject(parent)
{
}

void ProcessingWorker::process(const QString &filePath)
{
    QElapsedTimer timer;
    timer.start();

    QImage original(filePath);
    if (original.isNull()) {
        emit finished(QImage(), 0.0, timer.elapsed());
        return;
    }

    QImage gray = original.convertToFormat(QImage::Format_Grayscale8);

    qint64 sum = 0;
    const int w = gray.width();
    const int h = gray.height();

    for (int y = 0; y < h; ++y) {
        const uchar *line = gray.constScanLine(y);
        for (int x = 0; x < w; ++x) {
            sum += line[x];
        }
    }

    const qreal meanBrightness = (w > 0 && h > 0)
                                     ? qreal(sum) / qreal(w * h)
                                     : 0.0;

    emit finished(gray, meanBrightness, timer.elapsed());
}
