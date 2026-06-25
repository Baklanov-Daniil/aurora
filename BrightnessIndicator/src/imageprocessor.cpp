#include "imageprocessor.h"
#include "processingworker.h"
#include "resultimageprovider.h"

ImageProcessor::ImageProcessor(ResultImageProvider *provider, QObject *parent)
    : QObject(parent)
    , m_provider(provider)
{
    m_worker = new ProcessingWorker;
    m_worker->moveToThread(&m_thread);

    connect(&m_thread, &QThread::finished,
            m_worker, &QObject::deleteLater);

    connect(this, &ImageProcessor::processRequested,
            m_worker, &ProcessingWorker::process);

    connect(m_worker, &ProcessingWorker::finished,
            this,     &ImageProcessor::handleFinished);

    m_thread.start();
}

ImageProcessor::~ImageProcessor()
{
    m_thread.quit();
    m_thread.wait();
}

void ImageProcessor::process(const QString &filePath)
{
    if (m_busy) {
        return;
    }

    m_busy = true;
    emit busyChanged();
    emit processRequested(filePath);
}

void ImageProcessor::handleFinished(const QImage &result,
                                    qreal meanBrightness,
                                    int elapsedMs)
{
    m_provider->setImage(result);
    ++m_version;

    m_meanBrightness = meanBrightness;
    m_elapsedMs      = elapsedMs;
    m_resultSource   = QStringLiteral("image://result/processed/%1")
                         .arg(m_version);

    m_busy = false;

    emit resultSourceChanged();
    emit meanBrightnessChanged();
    emit elapsedMsChanged();
    emit busyChanged();
}
