#pragma once

#include <QObject>
#include <memory>

class ConversationModel;
class MessageModel;
class ContactModel;
class MessageController;
class ConversationController;

class MessagesApplication : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ConversationModel* conversationModel READ conversationModel CONSTANT)
    Q_PROPERTY(MessageModel* messageModel READ messageModel CONSTANT)
    Q_PROPERTY(ContactModel* contactModel READ contactModel CONSTANT)
    Q_PROPERTY(MessageController* messageController READ messageController CONSTANT)
    Q_PROPERTY(ConversationController* conversationController READ conversationController CONSTANT)

public:
    explicit MessagesApplication(QObject *parent = nullptr);
    ~MessagesApplication() override;

    bool initialize();

    ConversationModel* conversationModel() const { return m_conversationModel.get(); }
    MessageModel* messageModel() const { return m_messageModel.get(); }
    ContactModel* contactModel() const { return m_contactModel.get(); }
    MessageController* messageController() const { return m_messageController.get(); }
    ConversationController* conversationController() const { return m_conversationController.get(); }

private:
    std::unique_ptr<ConversationModel> m_conversationModel;
    std::unique_ptr<MessageModel> m_messageModel;
    std::unique_ptr<ContactModel> m_contactModel;
    std::unique_ptr<MessageController> m_messageController;
    std::unique_ptr<ConversationController> m_conversationController;
};