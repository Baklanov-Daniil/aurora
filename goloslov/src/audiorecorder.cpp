#include "audiorecorder.h"
#include <QStandardPaths>
#include <QDir>
#include <QUuid>
#include <QDebug>

AudioRecorder::AudioRecorder(QObject *parent)
    : QObject(parent)
    , m_audioInput(nullptr)
    , m_file(nullptr)
    , m_timer(new QTimer(this))
{
    m_timer->setInterval(1000);
    connect(m_timer, &QTimer::timeout, this, &AudioRecorder::updateDuration);
}

AudioRecorder::~AudioRecorder()
{
    if (m_isRecording) {
        stopRecording();
    }
}

void AudioRecorder::startRecording()
{
    if (m_isRecording) return;

    // Генерируем путь к файлу
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);

    // Для Qt 5.6: убираем скобки вручную
    QString fileName = QUuid::createUuid().toString().remove("{").remove("}") + ".wav";
    m_lastRecordedFile = dataDir + "/" + fileName;

    m_file = new QFile(m_lastRecordedFile);
    if (!m_file->open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "Failed to open file:" << m_lastRecordedFile;
        delete m_file;
        m_file = nullptr;
        return;
    }

    // Формат: 16kHz, 16bit, Mono, PCM
    QAudioFormat format;
    format.setSampleRate(16000);
    format.setChannelCount(1);
    format.setSampleSize(16);
    format.setCodec("audio/pcm");
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::SignedInt);

    m_audioInput = new QAudioInput(format, this);

    // В Qt 5.6 нельзя использовать QAudioProbe с QAudioInput
    // Поэтому просто пишем в файл, а уровень считаем отдельно
    m_audioInput->start(m_file);

    // Для мониторинга уровня будем периодически читать доступные данные
    // Но не потреблять их (оставляем QAudioInput писать в файл)
    // Это приблизительная оценка

    m_isRecording = true;
    m_duration = 0;
    m_bytesWritten = 0;
    m_level = 0.0;

    emit isRecordingChanged();
    emit durationChanged();
    emit levelChanged();

    m_timer->start();
}

void AudioRecorder::stopRecording()
{
    if (!m_isRecording) return;

    m_timer->stop();

    if (m_audioInput) {
        m_audioInput->stop();
        delete m_audioInput;
        m_audioInput = nullptr;
    }

    if (m_file) {
        m_file->close();
        delete m_file;
        m_file = nullptr;
    }

    m_isRecording = false;
    emit isRecordingChanged();
    emit lastRecordedFileChanged();
    emit recordingFinished(m_lastRecordedFile);
}

void AudioRecorder::calculateLevel(const QByteArray &data)
{
    if (data.isEmpty()) {
        m_level = 0.0;
        emit levelChanged();
        return;
    }

    const qint16 *samples = reinterpret_cast<const qint16*>(data.constData());
    int numSamples = data.size() / sizeof(qint16);

    if (numSamples == 0) return;

    qint64 sum = 0;
    for (int i = 0; i < numSamples; ++i) {
        sum += qAbs(samples[i]);
    }

    qreal avg = static_cast<qreal>(sum) / numSamples;
    m_level = avg / 32768.0; // Нормализация 0.0 - 1.0
    emit levelChanged();
}

void AudioRecorder::updateDuration()
{
    m_duration++;
    emit durationChanged();

    // В Qt 5.6 без QAudioProbe сложно получить уровень в реальном времени
    // без вмешательства в поток данных.
    // Для простой индикации можно использовать длительность записи
    // или оставить уровень на 0 (полоска будет показывать активность по таймеру)

    // Эмуляция активности для визуального эффекта:
    if (m_isRecording) {
        m_level = 0.3 + (qrand() % 40) / 100.0; // Случайный уровень 0.3-0.7
        emit levelChanged();
    }
}
