#pragma once

#include <QObject>

class ConversationModel;
class ContactModel;

class ConversationController : public QObject
{
    Q_OBJECT

public:
    explicit ConversationController(ConversationModel *conversationModel, ContactModel *contactModel, QObject *parent = nullptr);
    ~ConversationController() override;

    bool initialize();

    Q_INVOKABLE void startConversation(const QString &contactId);
    Q_INVOKABLE void startGroupConversation(const QStringList &contactIds, const QString &groupName);
    Q_INVOKABLE void addParticipant(const QString &conversationId, const QString &contactId);
    Q_INVOKABLE void removeParticipant(const QString &conversationId, const QString &contactId);
    Q_INVOKABLE void leaveGroup(const QString &conversationId);
    Q_INVOKABLE void updateGroupInfo(const QString &conversationId, const QString &name, const QString &avatar);
    Q_INVOKABLE void muteConversation(const QString &conversationId);
    Q_INVOKABLE void unmuteConversation(const QString &conversationId);
    Q_INVOKABLE void pinConversation(const QString &conversationId);
    Q_INVOKABLE void unpinConversation(const QString &conversationId);
    Q_INVOKABLE void archiveConversation(const QString &conversationId);
    Q_INVOKABLE void unarchiveConversation(const QString &conversationId);

signals:
    void conversationCreated(const QString &conversationId);
    void conversationUpdated(const QString &conversationId);
    void conversationDeleted(const QString &conversationId);

private:
    QObject *m_conversationModel = nullptr;
    QObject *m_contactModel = nullptr;
};