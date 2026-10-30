#include "MeridianShell.h"
#include "compositor/MeridianCompositor.h"
#include "input/InputManager.h"
#include "gestures/GestureRecognizer.h"
#include <QScreen>
#include <QGuiApplication>
#include <QSettings>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

MeridianShell::MeridianShell(QObject *parent)
    : QObject(parent)
{
}

MeridianShell::~MeridianShell() = default;

bool MeridianShell::initialize()
{
    qInfo() << "Initializing Meridian Shell...";

    // Load configuration
    loadConfiguration();

    // Create compositor
    m_compositor = std::make_unique<MeridianCompositor>(this);
    if (!m_compositor->initialize()) {
        qCritical() << "Failed to initialize compositor";
        return false;
    }

    // Create input manager
    m_inputManager = std::make_unique<InputManager>(this);
    if (!m_inputManager->initialize()) {
        qCritical() << "Failed to initialize input manager";
        return false;
    }

    // Create gesture recognizer
    m_gestureRecognizer = std::make_unique<GestureRecognizer>(this);
    m_gestureRecognizer->setShellMode(m_mode);

    // Setup connections
    setupConnections();

    // Apply mode
    applyMode();

    m_active = true;
    qInfo() << "Meridian Shell initialized successfully";
    return true;
}

void MeridianShell::setMode(Mode mode)
{
    if (m_mode != mode) {
        m_mode = mode;
        applyMode();
        emit modeChanged(mode);
        m_gestureRecognizer->setShellMode(mode);
    }
}

void MeridianShell::setCurrentProfile(const QString &profile)
{
    if (m_currentProfile != profile) {
        m_currentProfile = profile;
        
        // Save to settings
        QSettings settings("MeridianOS", "Shell");
        settings.setValue("powerProfile", profile);
        
        emit profileChanged(profile);
    }
}

void MeridianShell::showHome()
{
    emit homeRequested();
}

void MeridianShell::showAppGrid()
{
    emit appGridRequested();
}

void MeridianShell::showQuickSettings()
{
    emit quickSettingsRequested();
}

void MeridianShell::showNotifications()
{
    emit notificationsRequested();
}

void MeridianShell::showAppDrawer()
{
    emit appDrawerRequested();
}

void MeridianShell::closeAllPanels()
{
    // Close all open panels
    emit closeAllPanelsRequested();
}

void MeridianShell::setTheme(const QString &theme)
{
    // Apply theme
    QSettings settings("MeridianOS", "Shell");
    settings.setValue("theme", theme);
    // Apply to QML engine
}

void MeridianShell::toggleTheme()
{
    // Toggle between dark/light/high-contrast
    QSettings settings("MeridianOS", "Shell");
    QString current = settings.value("theme", "dark").toString();
    QString newTheme = (current == "dark") ? "light" : "dark";
    setTheme(newTheme);
}

void MeridianShell::setupConnections()
{
    // Connect compositor signals
    connect(m_compositor.get(), &MeridianCompositor::screenAdded,
            this, &MeridianShell::onScreenAdded);
    connect(m_compositor.get(), &MeridianCompositor::screenRemoved,
            this, &MeridianShell::onScreenRemoved);

    // Connect input manager signals
    connect(m_inputManager.get(), &InputManager::keyPressed,
            this, &MeridianShell::onKeyPressed);
    connect(m_inputManager.get(), &InputManager::touchEvent,
            this, &MeridianShell::onTouchEvent);

    // Connect gesture recognizer
    connect(m_gestureRecognizer.get(), &GestureRecognizer::edgeSwipeDetected,
            this, &MeridianShell::onEdgeSwipe);
    connect(m_gestureRecognizer.get(), &GestureRecognizer::pinchDetected,
            this, &MeridianShell::onPinch);
    connect(m_gestureRecognizer.get(), &GestureRecognizer::threeFingerTap,
            this, &MeridianShell::onThreeFingerTap);
}

void MeridianShell::applyMode()
{
    qInfo() << "Applying shell mode:" << m_mode;
    
    // Configure compositor for mode
    m_compositor->setShellMode(m_mode);
    
    // Configure gesture recognizer
    m_gestureRecognizer->setShellMode(m_mode);
    
    // Apply mode-specific settings
    switch (m_mode) {
    case Phone:
        // Phone: single column, edge gestures, bottom dock
        break;
    case Tablet:
        // Tablet: two-column, side panel, top bar
        break;
    case Desktop:
        // Desktop: window management, top panel, dock
        break;
    }
}

void MeridianShell::loadConfiguration()
{
    QSettings settings("MeridianOS", "Shell");
    m_mode = static_cast<Mode>(settings.value("mode", Phone).toInt());
    m_currentProfile = settings.value("powerProfile", "balanced").toString();
}

void MeridianShell::onScreenAdded(QScreen *screen)
{
    qInfo() << "Screen added:" << screen->name() << screen->geometry();
    applyMode();
}

void MeridianShell::onScreenRemoved(QScreen *screen)
{
    qInfo() << "Screen removed:" << screen->name();
    applyMode();
}

void MeridianShell::onKeyPressed(Qt::Key key, Qt::KeyboardModifiers modifiers)
{
    // Handle global shortcuts
    if (modifiers & Qt::ControlModifier) {
        if (key == Qt::Key_T) {
            toggleTheme();
        }
    }
}

void MeridianShell::onTouchEvent(QTouchEvent *event)
{
    m_gestureRecognizer->processTouchEvent(event);
}

void MeridianShell::onEdgeSwipe(GestureRecognizer::Edge edge, qreal progress)
{
    qDebug() << "Edge swipe:" << edge << "progress:" << progress;
    
    switch (edge) {
    case GestureRecognizer::LeftEdge:
        if (progress > 0.8) emit homeRequested();
        break;
    case GestureRecognizer::RightEdge:
        if (progress > 0.8) emit quickSettingsRequested();
        break;
    case GestureRecognizer::TopEdge:
        if (progress > 0.8) emit notificationsRequested();
        break;
    case GestureRecognizer::BottomEdge:
        if (progress > 0.8) emit homeRequested();
        break;
    }
}

void MeridianShell::onPinch(qreal scale, const QPointF &center)
{
    qDebug() << "Pinch:" << scale << "center:" << center;
    // Handle pinch zoom
}

void MeridianShell::onThreeFingerTap()
{
    emit notificationsRequested();
}