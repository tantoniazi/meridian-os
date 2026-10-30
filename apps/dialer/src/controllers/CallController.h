#pragma once

#include <QObject>
#include <QTimer>

class CallModel;

class CallController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasActiveCall READ hasActiveCall NOTIFY activeCallChanged)

public:
    explicit CallController(CallModel *callModel, QObject *parent = nullptr);
    ~CallController() override;

    bool initialize();

    bool hasActiveCall() const { return m_hasActiveCall; }

    Q_INVOKABLE void dial(const QString &number);
    Q_INVOKABLE void answer();
    Q_INVOKABLE void reject();
    Q_INVOKABLE void hangup();
    Q_INVOKABLE void hold();
    Q_INVOKABLE void resume();
    Q_INVOKABLE void mute();
    Q_INVOKABLE void unmute();
    Q_INVOKABLE void toggleSpeaker();
    Q_INVOKABLE void toggleVideo();
    Q_INVOKABLE void sendDTMF(const QString &tones);
    Q_INVOKABLE void startVideoCall(const QString &number);
    Q_INVOKABLE void startConferenceCall(const QStringList &numbers);

    bool dialNumber(const QString &number);
    bool answerCall();
    bool endCall();

signals:
    void activeCallChanged(bool active);
    void callStateChanged(int state);
    void callDurationChanged(int seconds);
    void incomingCall(const QString &number, const QString &name);
    void callEnded(const QString &number, int duration);
    void callError(const QString &error);

private:
    CallModel *m_callModel = nullptr;
    bool m_hasActiveCall = false;
    QTimer *m_callTimer = nullptr;
    int m_callDuration = 0;
    QString m_currentCallNumber;

    void onCallStateChanged(int state);
    void updateCallDuration();
    void handleIncomingCall(const QString &number, const QString &name);
    void handleCallEnded(int duration);
};