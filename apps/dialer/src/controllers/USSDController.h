#pragma once

#include <QObject>

class USSDModel;

class USSDController : public QObject
{
    Q_OBJECT

public:
    explicit USSDController(USSDModel *ussdModel, QObject *parent = nullptr);
    ~USSDController() override;

    bool initialize();

    Q_INVOKABLE void sendUSSD(const QString &code);
    Q_INVOKABLE void cancelUSSD();
    Q_INVOKABLE void respondToUSSD(const QString &response);
    Q_INVOKABLE void cancelSession(const QString &sessionId);
    Q_INVOKABLE void retrySession(const QString &sessionId);

signals:
    void ussdReceived(const QString &message);
    void ussdSessionStarted(const QString &sessionId);
    void ussdSessionEnded(const QString &sessionId, bool success);
    void ussdError(const QString &error);

private:
    USSDModel *m_ussdModel = nullptr;
    QString m_currentSessionId;
    QString m_pendingCode;
};