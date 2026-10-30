#include "InputManager.h"
#include <QTouchEvent>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QHoverEvent>
#include <QWheelEvent>
#include <QTabletEvent>
#include <QGuiApplication>
#include <QDebug>

InputManager::InputManager(QObject *parent)
    : QObject(parent)
{
}

InputManager::~InputManager() = default;

bool InputManager::initialize()
{
    qInfo() << "Initializing Input Manager...";
    
    // Install event filter on application
    qApp->installEventFilter(this);
    
    m_initialized = true;
    qInfo() << "Input Manager initialized";
    return true;
}

bool InputManager::eventFilter(QObject *watched, QEvent *event)
{
    switch (event->type()) {
    case QEvent::TouchBegin:
    case QEvent::TouchUpdate:
    case QEvent::TouchEnd:
    case QEvent::TouchCancel:
        processTouchEvent(static_cast<QTouchEvent*>(event));
        break;
    case QEvent::MouseButtonPress:
    case QEvent::MouseButtonRelease:
    case QEvent::MouseMove:
    case QEvent::MouseButtonDblClick:
        processMouseEvent(static_cast<QMouseEvent*>(event));
        break;
    case QEvent::KeyPress:
    case QEvent::KeyRelease:
        processKeyEvent(static_cast<QKeyEvent*>(event));
        break;
    case QEvent::HoverEnter:
    case QEvent::HoverLeave:
    case QEvent::HoverMove:
        processHoverEvent(static_cast<QHoverEvent*>(event));
        break;
    case QEvent::Wheel:
        processWheelEvent(static_cast<QWheelEvent*>(event));
        break;
    case QEvent::TabletPress:
    case QEvent::TabletRelease:
    case QEvent::TabletMove:
        processTabletEvent(static_cast<QTabletEvent*>(event));
        break;
    default:
        break;
    }
    
    return QObject::eventFilter(watched, event);
}

void InputManager::processTouchEvent(QTouchEvent *event)
{
    if (!event) return;
    emit touchEvent(event);
}

void InputManager::processMouseEvent(QMouseEvent *event)
{
    if (!event) return;
    emit mouseEvent(event);
}

void InputManager::processKeyEvent(QKeyEvent *event)
{
    if (!event) return;
    
    if (event->type() == QEvent::KeyPress) {
        emit keyPressed(event->key(), event->modifiers());
    } else if (event->type() == QEvent::KeyRelease) {
        emit keyReleased(event->key(), event->modifiers());
    }
}

void InputManager::processHoverEvent(QHoverEvent *event)
{
    if (!event) return;
    emit hoverEvent(event);
}

void InputManager::processWheelEvent(QWheelEvent *event)
{
    if (!event) return;
    emit wheelEvent(event);
}

void InputManager::processTabletEvent(QTabletEvent *event)
{
    if (!event) return;
    emit tabletEvent(event);
}