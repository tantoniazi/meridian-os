#include "W10MNavigation.h"
#include <QDebug>

W10MNavigation::W10MNavigation(QObject *parent)
    : QObject(parent)
{
}

W10MNavigation::~W10MNavigation() = default;

bool W10MNavigation::initialize()
{
    qInfo() << "Initializing W10M Navigation...";
    m_history.clear();
    m_historyIndex = -1;
    m_currentView = "start";
    qInfo() << "W10M Navigation initialized";
    return true;
}

void W10MNavigation::setCurrentView(const QString &view)
{
    if (m_currentView != view) {
        addToHistory(view);
        updateCurrentView(view);
    }
}

void W10MNavigation::navigateTo(const QString &view)
{
    setCurrentView(view);
    emit navigateTo(view);
}

void W10MNavigation::goBack()
{
    if (m_historyIndex > 0) {
        m_historyIndex--;
        QString previousView = m_history[m_historyIndex];
        updateCurrentView(previousView);
        emit backRequested();
    }
}

void W10MNavigation::goForward()
{
    if (m_historyIndex < m_history.size() - 1) {
        m_historyIndex++;
        QString nextView = m_history[m_historyIndex];
        updateCurrentView(nextView);
        emit forwardRequested();
    }
}

void W10MNavigation::goHome()
{
    navigateTo("start");
}

void W10MNavigation::goToStartScreen()
{
    navigateTo("start");
}

void W10MNavigation::goToAllApps()
{
    navigateTo("allapps");
}

void W10MNavigation::goToActionCenter()
{
    navigateTo("actioncenter");
}

void W10MNavigation::goToSettings()
{
    navigateTo("settings");
}

void W10MNavigation::goToLockScreen()
{
    navigateTo("lockscreen");
}

void W10MNavigation::goToCallView()
{
    navigateTo("call");
}

void W10MNavigation::goToMessageView()
{
    navigateTo("messages");
}

void W10MNavigation::addToHistory(const QString &view)
{
    // Remove any forward history
    while (m_history.size() > m_historyIndex + 1) {
        m_history.removeLast();
    }
    
    m_history.append(view);
    m_historyIndex = m_history.size() - 1;
}

void W10MNavigation::updateCurrentView(const QString &view)
{
    if (m_currentView != view) {
        m_currentView = view;
        emit currentViewChanged(view);
    }
}