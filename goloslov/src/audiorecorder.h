#ifndef AUDIORECORDER_H
#define AUDIORECORDER_H

#include <QObject>
#include <QAudioInput>
#include <QFile>
#include <QTimer>
#include <QQueue>

class AudioRecorder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(qreal level READ level NOTIFY levelChanged)
    Q_PROPERTY(QString lastRecordedFile READ lastRecordedFile NOTIFY lastRecordedFileChanged)

public:
    explicit AudioRecorder(QObject *parent = nullptr);
    ~AudioRecorder();

    bool isRecording() const { return m_isRecording; }
    int duration() const { return m_duration; }
    qreal level() const { return m_level; }
    QString lastRecordedFile() const { return m_lastRecordedFile; }

    Q_INVOKABLE void startRecording();
    Q_INVOKABLE void stopRecording();

signals:
    void isRecordingChanged();
    void durationChanged();
    void levelChanged();
    void lastRecordedFileChanged();
    void recordingFinished(const QString &filePath);

private slots:
    void updateDuration();

private:
    void calculateLevel(const QByteArray &data);

    QAudioInput *m_audioInput;
    QFile *m_file;
    QTimer *m_timer;

    bool m_isRecording = false;
    int m_duration = 0;
    qreal m_level = 0.0;
    QString m_lastRecordedFile;
    qint64 m_bytesWritten = 0;
};

#endif // AUDIORECORDER_H
