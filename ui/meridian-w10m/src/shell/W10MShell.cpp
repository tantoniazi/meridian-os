#include "W10MShell.h"
#include "src/shell/W10MCompositor.h"
#include "src/shell/W10MNavigation.h"
#include "src/input/W10MInputManager.h"
#include "src/animations/W10MAnimationManager.h"
#include "models/W10MAppModel.h"
#include "models/W10MTileModel.h"
#include "models/W10MSettingsModel.h"
#include <QScreen>
#include <QGuiApplication>
#include <QSettings>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

W10MShell::W10MShell(QObject *parent)
    : QObject(parent)
{
}

W10MShell::~W10MShell() = default;

bool W10MShell::initialize()
{
    qInfo() << "Initializing Meridian W10M Shell...";

    // Load configuration
    loadConfiguration();

    // Create models
    m_appModel = std::make_unique<W10MAppModel>(this);
    m_tileModel = std::make_unique<W10MTileModel>(this);
    m_settingsModel = std::make_unique<W10MSettingsModel>(this);

    // Create compositor
    m_compositor = std::make_unique<W10MCompositor>(this);
    if (!m_compositor->initialize()) {
        qCritical() << "Failed to initialize compositor";
        return false;
    }

    // Create navigation
    m_navigation = std::make_unique<W10MNavigation>(this);
    m_navigation->initialize();

    // Create input manager
    m_inputManager = std::make_unique<W10MInputManager>(this);
    if (!m_inputManager->initialize()) {
        qCritical() << "Failed to initialize input manager";
        return false;
    }

    // Create animation manager
    m_animationManager = std::make_unique<W10MAnimationManager>(this);
    m_animationManager->initialize();

    // Setup connections
    setupConnections();

    // Apply mode and theme
    applyMode();
    applyTheme();

    m_active = true;
    qInfo() << "Meridian W10M Shell initialized successfully";
    return true;
}

void W10MShell::setMode(ShellMode mode)
{
    if (m_mode != mode) {
        m_mode = mode;
        applyMode();
        emit modeChanged(mode);
    }
}

void W10MShell::setCurrentTheme(const QString &theme)
{
    if (m_currentTheme != theme) {
        m_currentTheme = theme;
        applyTheme();
        emit themeChanged(theme);
    }
}

void W10MShell::showStartScreen()
{
    emit startScreenRequested();
}

void W10MShell::showAllApps()
{
    emit allAppsRequested();
}

void W10MShell::showActionCenter()
{
    emit actionCenterRequested();
}

void W10MShell::showSettings()
{
    emit settingsRequested();
}

void W10MShell::showLockScreen()
{
    emit lockScreenRequested();
}

void W10MShell::showCallView()
{
    emit callViewRequested();
}

void W10MShell::showMessageView()
{
    emit messageViewRequested();
}

void W10MShell::setTheme(const QString &theme)
{
    setCurrentTheme(theme);
}

void W10MShell::toggleTheme()
{
    QString newTheme = (m_currentTheme == "dark") ? "light" : "dark";
    setCurrentTheme(newTheme);
}

void W10MShell::setupConnections()
{
    // Connect navigation signals
    connect(m_navigation.get(), &W10MNavigation::navigateTo,
            this, &W10MShell::onNavigationRequested);
    
    // Connect settings changes
    connect(m_settingsModel.get(), &W10MSettingsModel::themeChanged,
            this, &W10MShell::onThemeChanged);
}

void W10MShell::applyMode()
{
    qInfo() << "Applying shell mode:" << m_mode;
    
    // Configure for current mode
    switch (m_mode) {
    case PhoneMode:
        // Phone: Start screen with live tiles, app list, action center
        break;
    case TabletMode:
        // Tablet: Split view, snap views, taskbar
        break;
    case DesktopMode:
        // Desktop: Windowed apps, taskbar, start menu
        break;
    }
}

void W10MShell::applyTheme()
{
    qInfo() << "Applying theme:" << m_currentTheme;
    
    // Apply theme to QML engine
    // This would be implemented in QML layer
}

void W10MShell::loadConfiguration()
{
    QSettings settings("MeridianOS", "W10M");
    m_mode = static_cast<ShellMode>(settings.value("mode", PhoneMode).toInt());
    m_currentTheme = settings.value("theme", "dark").toString();
}

void W10MShell::onNavigationRequested(const QString &view)
{
    qInfo() << "Navigation requested to:" << view;
    
    if (view == "start") {
        emit startScreenRequested();
    } else if (view == "allapps") {
        emit allAppsRequested();
    } else if (view == "actioncenter") {
        emit actionCenterRequested();
    } else if (view == "settings") {
        emit settingsRequested();
    } else if (view == "lockscreen") {
        emit lockScreenRequested();
    } else if (view == "call") {
        emit callViewRequested();
    } else if (view == "messages") {
        emit messageViewRequested();
    }
}

void W10MShell::onThemeChanged(const QString &theme)
{
    setCurrentTheme(theme);
}