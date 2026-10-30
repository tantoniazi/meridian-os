#include "HomeApplication.h"
#include "models/AppModel.h"
#include "models/WidgetModel.h"
#include "models/SettingsModel.h"
#include <QSettings>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

HomeApplication::HomeApplication(QObject *parent)
    : QObject(parent)
{
}

HomeApplication::~HomeApplication() = default;

bool HomeApplication::initialize()
{
    qInfo() << "Initializing Meridian Home...";
    
    // Setup settings
    m_settings = std::make_unique<QSettings>("MeridianOS", "Home");
    
    // Initialize models
    m_appModel = std::make_unique<AppModel>(this);
    m_widgetModel = std::make_unique<WidgetModel>(this);
    m_settingsModel = std::make_unique<SettingsModel>(this);
    
    // Load applications
    if (!m_appModel->loadApplications()) {
        qWarning() << "Failed to load applications";
    }
    
    // Load widgets
    if (!m_widgetModel->loadWidgets()) {
        qWarning() << "Failed to load widgets";
    }
    
    // Load settings
    if (!m_settingsModel->loadSettings()) {
        qWarning() << "Failed to load settings";
    }
    
    qInfo() << "Meridian Home initialized successfully";
    return true;
}