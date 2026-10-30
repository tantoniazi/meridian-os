#include "MessagesApplication.h"
#include "models/ConversationModel.h"
#include "models/MessageModel.h"
#include "models/ContactModel.h"
#include "controllers/MessageController.h"
#include "controllers/ConversationController.h"
#include <QDebug>

MessagesApplication::MessagesApplication(QObject *parent)
    : QObject(parent)
{
}

MessagesApplication::~MessagesApplication() = default;

bool MessagesApplication::initialize()
{
    qInfo() << "Initializing Meridian Messages...";
    
    // Initialize models
    m_conversationModel = std::make_unique<ConversationModel>(this);
    m_messageModel = std::make_unique<MessageModel>(this);
    m_contactModel = std::make_unique<ContactModel>(this);
    
    // Initialize controllers
    m_messageController = std::make_unique<MessageController>(m_messageModel.get(), m_conversationModel.get(), this);
    m_conversationController = std::make_unique<ConversationController>(m_conversationModel.get(), m_contactModel.get(), this);
    
    // Initialize models
    if (!m_conversationModel->loadConversations()) {
        qWarning() << "Failed to load conversations";
    }
    
    if (!m_messageModel->loadMessages()) {
        qWarning() << "Failed to load messages";
    }
    
    if (!m_contactModel->loadContacts()) {
        qWarning() << "Failed to load contacts";
    }
    
    // Initialize controllers
    if (!m_messageController->initialize()) {
        qWarning() << "Failed to initialize message controller";
    }
    
    if (!m_conversationController->initialize()) {
        qWarning() << "Failed to initialize conversation controller";
    }
    
    qInfo() << "Meridian Messages initialized successfully";
    return true;
}