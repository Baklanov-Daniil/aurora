#ifndef VOSKWORKER_H
#define VOSKWORKER_H

#include <QObject>
#include <QString>
#include <QByteArray>

struct VoskModel;
struct VoskRecognizer;

class VoskWorker : public QObject
{
    Q_OBJECT
public:
    explicit VoskWorker(QObject *parent = nullptr);
    ~VoskWorker() override;

public slots:
    void load(const QString &modelPath, int sampleRate);
    void feed(const QByteArray &pcm);
    void finalize();
    void reset();

signals:
    void loaded(bool ok, const QString &message);
    void utterance(const QString &text);
    void finalUtterance(const QString &text);
    void partial(const QString &text);

private:
    static QString parseField(const char *json, const QString &field);

    VoskModel *m_model;
    VoskRecognizer *m_rec;
};

#endif // VOSKWORKER_H
