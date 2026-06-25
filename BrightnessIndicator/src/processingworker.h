#ifndef PROCESSINGWORKER_H
#define PROCESSINGWORKER_H

#include <QObject>
#include <QImage>

class ProcessingWorker : public QObject
{
    Q_OBJECT

public:
    explicit ProcessingWorker(QObject *parent = nullptr);

public slots:
    void process(const QString &filePath);

signals:
    void finished(const QImage &result, qreal meanBrightness, int elapsedMs);
};

#endif // PROCESSINGWORKER_H
