#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#pragma once

#include <QObject>
#include <QThread>
#include <QImage>

class ProcessingWorker;
class ResultImageProvider;

class ImageProcessor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(qreal meanBrightness READ meanBrightness NOTIFY meanBrightnessChanged)
    Q_PROPERTY(int elapsedMs READ elapsedMs NOTIFY elapsedMsChanged)
    Q_PROPERTY(QString resultSource READ resultSource NOTIFY resultSourceChanged)

public:
    explicit ImageProcessor(ResultImageProvider *provider,
                            QObject *parent = nullptr);
    ~ImageProcessor();

    bool busy() const { return m_busy; }
    qreal meanBrightness() const { return m_meanBrightness; }
    int elapsedMs() const { return m_elapsedMs; }
    QString resultSource() const { return m_resultSource; }

    Q_INVOKABLE void process(const QString &filePath);

signals:
    void processRequested(const QString &filePath);
    void busyChanged();
    void meanBrightnessChanged();
    void elapsedMsChanged();
    void resultSourceChanged();

private slots:
    void handleFinished(const QImage &result, qreal meanBrightness, int elapsedMs);

private:
    ProcessingWorker     *m_worker;
    QThread               m_thread;
    ResultImageProvider  *m_provider;

    bool    m_busy           = false;
    qreal   m_meanBrightness = 0.0;
    int     m_elapsedMs      = 0;
    QString m_resultSource;
    int     m_version        = 0;
};

#endif // IMAGEPROCESSOR_H
