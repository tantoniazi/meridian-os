#include "DialerApplication.h"
#include "models/CallModel.h"
#include "models/ContactModel.h"
#include "models/USSDModel.h"
#include "controllers/CallController.h"
#include "controllers/ContactController.h"
#include "controllers/USSDController.h"
#include <QDebug>

DialerApplication::DialerApplication(QObject *parent)
    : QObject(parent)
{
}

DialerApplication::~DialerApplication() = default;

bool DialerApplication::initialize()
{
    qInfo() << "Initializing Meridian Dialer...";
    
    // Initialize models
    m_callModel = std::make_unique<CallModel>(this);
    m_contactModel = std::make_unique<ContactModel>(this);
    m_ussdModel = std::make_unique<USSDModel>(this);
    
    // Initialize controllers
    m_callController = std::make_unique<CallController>(m_callModel.get(), this);
    m_contactController = std::make_unique<ContactController>(m_contactModel.get(), this);
    m_ussdController = std::make_unique<USSDController>(m_ussdModel.get(), this);
    
    // Initialize models
    if (!m_callModel->loadCalls()) {
        qWarning() << "Failed to load call history";
    }
    
    if (!m_contactModel->loadContacts()) {
        qWarning() << "Failed to load contacts";
    }
    
    if (!m_ussdModel->loadUSSDSessions()) {
        qWarning() << "Failed to load USSD sessions";
    }
    
    // Initialize controllers
    if (!m_callController->initialize()) {
        qWarning() << "Failed to initialize call controller";
    }
    
    if (!m_contactController->initialize()) {
        qWarning() << "Failed to initialize contact controller";
    }
    
    if (!m_ussdController->initialize()) {
        qWarning() << "Failed to initialize USSD controller";
    }
    
    qInfo() << "Meridian Dialer initialized successfully";
    return true;
}