#pragma once

#include <QObject>

class MessageModel;
class ConversationModel;

class MessageController : public QObject
{
    Q_OBJECT

public:
    explicit MessageController(MessageModel *messageModel, ConversationModel *conversationModel, QObject *parent = nullptr);
    ~MessageController() override;

    bool initialize();

    Q_INVOKABLE void sendMessage(const QString &conversationId, const QString &body);
    Q_INVOKABLE void sendImage(const QString &conversationId, const QString &imagePath);
    Q_INVOKABLE void sendVideo(const QString &conversationId, const QString &videoPath);
    Q_INVOKABLE void sendAudio(const QString &conversationId, const QString &audioPath);
    Q_INVOKABLE void sendLocation(const QString &conversationId, double latitude, double longitude);
    Q_INVOKABLE void sendContact(const QString &conversationId, const QString &contactId);
    Q_INVOKABLE void resendMessage(const QString &messageId);
    Q_INVOKABLE void deleteMessage(const QString &messageId);
    Q_INVOKABLE void forwardMessage(const QString &messageId, const QStringList &conversationIds);
    Q_INVOKABLE void markAsRead(const QString &conversationId);
    Q_INVOKABLE void markAsUnread(const QString &conversationId);
    Q_INVOKABLE void deleteConversation(const QString &conversationId);

signals:
    void messageSent(const QString &conversationId, const QString &messageId);
    void messageFailed(const QString &conversationId, const QString &error);
    void messageDelivered(const QString &messageId);
    void messageRead(const QString &messageId);

private:
    QObject *m_messageModel = nullptr;
    QObject *m_conversationModel = nullptr;
};