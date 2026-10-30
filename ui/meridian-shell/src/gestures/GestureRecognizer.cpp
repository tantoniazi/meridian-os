#include "GestureRecognizer.h"
#include <QTouchEvent>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QScreen>
#include <QGuiApplication>
#include <QTimer>
#include <QDebug>
#include <cmath>

GestureRecognizer::GestureRecognizer(QObject *parent)
    : QObject(parent)
{
    qInfo() << "GestureRecognizer initialized";
}

GestureRecognizer::~GestureRecognizer() = default;

void GestureRecognizer::setShellMode(ShellMode mode)
{
    if (m_shellMode != mode) {
        m_shellMode = mode;
        qInfo() << "Gesture recognizer shell mode changed to:" << mode;
        emit shellModeChanged(mode);
    }
}

void GestureRecognizer::processTouchEvent(QTouchEvent *event)
{
    if (!event) return;
    
    switch (event->type()) {
    case QEvent::TouchBegin:
        processTouchBegin(event);
        break;
    case QEvent::TouchUpdate:
        processTouchUpdate(event);
        break;
    case QEvent::TouchEnd:
        processTouchEnd(event);
        break;
    case QEvent::TouchCancel:
        processTouchCancel(event);
        break;
    default:
        break;
    }
}

void GestureRecognizer::processTouchBegin(QTouchEvent *event)
{
    for (const QTouchEvent::TouchPoint &point : event->touchPoints()) {
        TouchPoint tp;
        tp.id = point.id();
        tp.startPos = point.startScreenPos();
        tp.lastPos = point.screenPos();
        tp.currentPos = point.screenPos();
        tp.startTime = event->timestamp();
        tp.moved = false;
        
        m_touchPoints[point.id()] = tp;
        
        // Start long press timer
        startLongPressTimer(point.id(), point.screenPos());
    }
    
    // Check for three-finger gestures
    if (m_touchPoints.size() >= 3) {
        detectThreeFingerGestures();
    }
}

void GestureRecognizer::processTouchUpdate(QTouchEvent *event)
{
    for (const QTouchEvent::TouchPoint &point : event->touchPoints()) {
        auto it = m_touchPoints.find(point.id());
        if (it == m_touchPoints.end()) continue;
        
        TouchPoint &tp = it.value();
        tp.lastPos = tp.currentPos;
        tp.currentPos = point.screenPos();
        tp.moved = true;
        
        // Check for long press
        if (!tp.moved && (event->timestamp() - tp.startTime) > LONG_PRESS_TIME) {
            // Long press will be handled by timer
        }
        
        // Detect gestures
        detectSwipe(*it);
        detectEdgeSwipe(*it);
    }
    
    // Multi-touch gestures
    if (m_touchPoints.size() >= 2) {
        detectPinch(nullptr); // Will use touch points
    }
    
    checkGestures();
}

void GestureRecognizer::processTouchEnd(QTouchEvent *event)
{
    for (const QTouchEvent::TouchPoint &point : event->touchPoints()) {
        auto it = m_touchPoints.find(point.id());
        if (it == m_touchPoints.end()) continue;
        
        const TouchPoint &tp = it.value();
        uint duration = event->timestamp() - tp.startTime;
        qreal distance = QLineF(tp.startPos, tp.currentPos).length();
        
        // Determine gesture type
        if (!tp.moved && distance <= TAP_MAX_DISTANCE && duration <= TAP_MAX_TIME) {
            // Check for double tap
            uint timeSinceLastTap = event->timestamp() - m_lastTapTime;
            qreal tapDistance = QLineF(tp.startPos, m_lastTapPos).length();
            
            if (timeSinceLastTap <= DOUBLE_TAP_MAX_TIME && tapDistance <= TAP_MAX_DISTANCE) {
                // Double tap
                GestureEvent event;
                event.type = DoubleTapGesture;
                event.position = tp.startPos;
                event.timestamp = event->timestamp();
                emitGestureEnded(event);
            } else {
                // Single tap
                GestureEvent event;
                event.type = TapGesture;
                event.position = tp.startPos;
                event.timestamp = event->timestamp();
                emitGestureEnded(event);
            }
            
            m_lastTapTime = event->timestamp();
            m_lastTapPos = tp.startPos;
            
        } else if (tp.moved && distance >= SWIPE_MIN_DISTANCE) {
            // Swipe gesture
            QLineF line(tp.startPos, tp.currentPos);
            qreal velocity = line.length() / (duration / 1000.0); // px/s
            
            if (velocity >= SWIPE_MIN_VELOCITY) {
                Qt::Edge edge;
                qreal dx = tp.currentPos.x() - tp.startPos.x();
                qreal dy = tp.currentPos.y() - tp.startPos.y();
                
                if (std::abs(dx) > std::abs(dy)) {
                    edge = (dx > 0) ? Qt::RightEdge : Qt::LeftEdge;
                } else {
                    edge = (dy > 0) ? Qt::BottomEdge : Qt::TopEdge;
                }
                
                emit swipeDetected(edge, velocity);
            }
        }
        
        // Stop long press timer
        if (m_longPressTimerId && m_longPressTouchId == point.id()) {
            stopLongPressTimer();
        }
        
        m_touchPoints.remove(point.id());
    }
    
    // Check for three-finger gestures on last finger up
    if (m_touchPoints.size() >= 2) {
        detectThreeFingerGestures();
    }
}

void GestureRecognizer::processTouchCancel(QTouchEvent *event)
{
    for (const QTouchEvent::TouchPoint &point : event->touchPoints()) {
        m_touchPoints.remove(point.id());
    }
    
    stopLongPressTimer();
    
    // Emit cancelled for any pending gestures
    GestureEvent event;
    event.type = NoGesture;
    event.timestamp = event->timestamp();
    emitGestureCancelled(event);
}

void GestureRecognizer::processMouseEvent(QMouseEvent *event)
{
    // Convert mouse events to touch-like events for desktop mode
    if (m_shellMode == DesktopMode) {
        // Implementation for desktop mouse handling
    }
}

void GestureRecognizer::processKeyEvent(QKeyEvent *event)
{
    // Handle keyboard shortcuts
    if (event->type() == QEvent::KeyPress) {
        if (event->modifiers() & Qt::ControlModifier) {
            if (event->key() == Qt::Key_T) {
                // Ctrl+T - toggle theme (handled by shell)
            }
        }
    }
}

void GestureRecognizer::processTouchBegin(QTouchEvent *event)
{
    for (const QTouchEvent::TouchPoint &point : event->touchPoints()) {
        TouchPoint tp;
        tp.id = point.id();
        tp.startPos = point.startScreenPos();
        tp.lastPos = point.screenPos();
        tp.currentPos = point.screenPos();
        tp.startTime = event->timestamp();
        tp.moved = false;
        
        m_touchPoints[point.id()] = tp;
        
        // Start long press timer
        startLongPressTimer(point.id(), point.screenPos());
    }
    
    // Check for three-finger gestures
    if (m_touchPoints.size() >= 3) {
        detectThreeFingerGestures();
    }
}

void GestureRecognizer::detectTap(const TouchPoint &point)
{
    // Handled in touch end
}

void GestureRecognizer::detectDoubleTap(const TouchPoint &point)
{
    // Handled in touch end
}

void GestureRecognizer::detectLongPress()
{
    // Timer-based detection
}

void GestureRecognizer::detectSwipe(const TouchPoint &point)
{
    if (!point.moved) return;
    
    qreal distance = QLineF(point.startPos, point.currentPos).length();
    if (distance < SWIPE_MIN_DISTANCE) return;
    
    // Check velocity
    // Velocity calculation would need time tracking
}

void GestureRecognizer::detectPinch(QTouchEvent *event)
{
    if (m_touchPoints.size() < 2) return;
    
    // Find two touch points
    auto it = m_touchPoints.begin();
    TouchPoint &p1 = it.value();
    ++it;
    if (it == m_touchPoints.end()) return;
    TouchPoint &p2 = it.value();
    
    // Current distance
    qreal currentDist = QLineF(p1.currentPos, p2.currentPos).length();
    // Start distance
    qreal startDist = QLineF(p1.startPos, p2.startPos).length();
    
    if (startDist > 0) {
        qreal scale = currentDist / startDist;
        qreal scaleChange = std::abs(scale - m_lastPinchScale);
        
        if (scaleChange >= PINCH_MIN_SCALE_CHANGE) {
            // Pinch detected
            QPointF center = (p1.currentPos + p2.currentPos) / 2.0;
            
            GestureEvent event;
            event.type = PinchGesture;
            event.position = center;
            event.scale = scale;
            event.timestamp = QDateTime::currentMSecsSinceEpoch();
            
            emitGestureUpdated(event);
            m_lastPinchScale = scale;
        }
    }
}

void GestureRecognizer::detectEdgeSwipe(const TouchPoint &point)
{
    if (m_shellMode == DesktopMode) return;
    
    Edge edge = getEdgeFromPosition(point.currentPos);
    if (edge == LeftEdge || edge == RightEdge || edge == TopEdge || edge == BottomEdge) {
        qreal progress = getEdgeProgress(point.currentPos, edge);
        
        if (progress >= EDGE_SWIPE_ACTIVATION) {
            GestureEvent event;
            event.type = SwipeGesture;
            event.edge = edge;
            event.position = point.currentPos;
            event.progress = progress;
            event.timestamp = QDateTime::currentMSecsSinceEpoch();
            
            emit edgeSwipeDetected(edge, progress);
        }
    }
}

void GestureRecognizer::detectThreeFingerGestures()
{
    if (m_touchPoints.size() < 3) return;
    
    // Check if three fingers are close together (tap) or spread (swipe)
    QList<QPointF> positions;
    for (auto it = m_touchPoints.begin(); it != m_touchPoints.end(); ++it) {
        positions.append(it.value().currentPos);
    }
    
    // Calculate bounding box
    qreal minX = positions[0].x(), maxX = positions[0].x();
    qreal minY = positions[0].y(), maxY = positions[0].y();
    
    for (const QPointF &pos : positions) {
        minX = std::min(minX, pos.x());
        maxX = std::max(maxX, pos.x());
        minY = std::min(minY, pos.y());
        maxY = std::max(maxY, pos.y());
    }
    
    qreal width = maxX - minX;
    qreal height = maxY - minY;
    
    // Three finger tap: fingers close together, no movement
    if (width < 100 && height < 100) {
        bool allStationary = true;
        for (auto it = m_touchPoints.begin(); it != m_touchPoints.end(); ++it) {
            if (it.value().moved) {
                allStationary = false;
                break;
            }
        }
        
        if (allStationary) {
            // Calculate center
            QPointF center(0, 0);
            for (const QPointF &pos : positions) {
                center += pos;
            }
            center /= positions.size();
            
            GestureEvent event;
            event.type = ThreeFingerTapGesture;
            event.position = center;
            event.fingerCount = 3;
            event.timestamp = QDateTime::currentMSecsSinceEpoch();
            
            emit threeFingerTapDetected(center);
        }
    }
    // Three finger swipe: fingers spread, moving together
    else {
        // Check if all moving in same direction
        // Simplified: emit three finger swipe
    }
}

GestureRecognizer::Edge GestureRecognizer::getEdgeFromPosition(const QPointF &pos) const
{
    QScreen *screen = QGuiApplication::primaryScreen();
    if (!screen) return LeftEdge;
    
    QRect geometry = screen->geometry();
    qreal edgeThreshold = EDGE_SWIPE_THRESHOLD;
    
    if (pos.x() <= edgeThreshold) return LeftEdge;
    if (pos.x() >= geometry.width() - edgeThreshold) return RightEdge;
    if (pos.y() <= edgeThreshold) return TopEdge;
    if (pos.y() >= geometry.height() - edgeThreshold) return BottomEdge;
    
    return LeftEdge; // Default
}

bool GestureRecognizer::isNearEdge(const QPointF &pos, Edge edge) const
{
    return getEdgeFromPosition(pos) == edge;
}

qreal GestureRecognizer::getEdgeProgress(const QPointF &pos, Edge edge) const
{
    QScreen *screen = QGuiApplication::primaryScreen();
    if (!screen) return 0.0;
    
    QRect geometry = screen->geometry();
    qreal threshold = EDGE_SWIPE_THRESHOLD * 3; // Progress measured over 3x threshold
    
    switch (edge) {
    case LeftEdge:
        return std::max(0.0, 1.0 - pos.x() / threshold);
    case RightEdge:
        return std::max(0.0, 1.0 - (geometry.width() - pos.x()) / threshold);
    case TopEdge:
        return std::max(0.0, 1.0 - pos.y() / threshold);
    case BottomEdge:
        return std::max(0.0, 1.0 - (geometry.height() - pos.y()) / threshold);
    }
    
    return 0.0;
}

void GestureRecognizer::emitGestureStarted(const GestureEvent &event)
{
    emit gestureStarted(event);
}

void GestureRecognizer::emitGestureUpdated(const GestureEvent &event)
{
    emit gestureUpdated(event);
}

void GestureRecognizer::emitGestureEnded(const GestureEvent &event)
{
    emit gestureEnded(event);
}

void GestureRecognizer::emitGestureCancelled(const GestureEvent &event)
{
    emit gestureCancelled(event);
}

void GestureRecognizer::startLongPressTimer(int touchId, const QPointF &pos)
{
    if (m_longPressTimerId != 0) return; // Already running
    
    m_longPressTouchId = touchId;
    m_longPressPos = pos;
    
    m_longPressTimerId = startTimer(LONG_PRESS_TIME);
}

void GestureRecognizer::stopLongPressTimer()
{
    if (m_longPressTimerId != 0) {
        killTimer(m_longPressTimerId);
        m_longPressTimerId = 0;
        m_longPressTouchId = -1;
    }
}

void GestureRecognizer::timerEvent(QTimerEvent *event)
{
    if (event->timerId() == m_longPressTimerId) {
        killTimer(m_longPressTimerId);
        m_longPressTimerId = 0;
        
        // Long press detected
        auto it = m_touchPoints.find(m_longPressTouchId);
        if (it != m_touchPoints.end()) {
            const TouchPoint &tp = it.value();
            
            GestureEvent event;
            event.type = LongPressGesture;
            event.position = tp.startPos;
            event.timestamp = QDateTime::currentMSecsSinceEpoch();
            
            emitGestureEnded(event);
            emit longPressDetected(tp.startPos);
        }
        
        m_longPressTouchId = -1;
    }
}

void GestureRecognizer::checkGestures()
{
    // Called on each touch update to check for ongoing gestures
    if (m_touchPoints.size() >= 2) {
        detectPinch(nullptr);
    }
    
    if (m_touchPoints.size() >= 3) {
        detectThreeFingerGestures();
    }
}