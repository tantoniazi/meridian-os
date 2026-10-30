#pragma once

#include <QObject>
#include <QTouchEvent>
#include <QGesture>
#include <QGestureRecognizer>
#include <QPointF>

class GestureRecognizer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ShellMode shellMode READ shellMode WRITE setShellMode NOTIFY shellModeChanged)

public:
    enum ShellMode {
        PhoneMode,
        TabletMode,
        DesktopMode
    };
    Q_ENUM(ShellMode)

    enum Edge {
        LeftEdge,
        RightEdge,
        TopEdge,
        BottomEdge
    };
    Q_ENUM(Edge)

    enum GestureType {
        NoGesture,
        TapGesture,
        DoubleTapGesture,
        LongPressGesture,
        SwipeGesture,
        PinchGesture,
        PanGesture,
        EdgeSwipeGesture,
        ThreeFingerTapGesture,
        ThreeFingerSwipeGesture
    };
    Q_ENUM(GestureType)

    struct GestureEvent {
        GestureType type = NoGesture;
        QPointF position;
        QPointF globalPosition;
        qreal progress = 0.0;
        qreal scale = 1.0;
        qreal rotation = 0.0;
        Qt::KeyboardModifiers modifiers;
        Edge edge = LeftEdge;
        int fingerCount = 1;
        uint timestamp = 0;
    };

    explicit GestureRecognizer(QObject *parent = nullptr);
    ~GestureRecognizer() override;

    void setShellMode(ShellMode mode);
    ShellMode shellMode() const { return m_shellMode; }

    Q_INVOKABLE void processTouchEvent(QTouchEvent *event);
    Q_INVOKABLE void processMouseEvent(QMouseEvent *event);
    Q_INVOKABLE void processKeyEvent(QKeyEvent *event);

signals:
    void shellModeChanged(ShellMode mode);
    
    // Gesture signals
    void gestureStarted(const GestureEvent &event);
    void gestureUpdated(const GestureEvent &event);
    void gestureEnded(const GestureEvent &event);
    void gestureCancelled(const GestureEvent &event);
    
    // Specific gesture signals
    void tapDetected(const QPointF &position);
    void doubleTapDetected(const QPointF &position);
    void longPressDetected(const QPointF &position);
    void swipeDetected(Qt::Edge edge, qreal velocity);
    void pinchDetected(qreal scale, const QPointF &center);
    void edgeSwipeDetected(Edge edge, qreal progress);
    void threeFingerTapDetected(const QPointF &position);
    void threeFingerSwipeDetected(Qt::Edge direction);

private:
    ShellMode m_shellMode = PhoneMode;
    
    struct TouchPoint {
        int id = -1;
        QPointF startPos;
        QPointF lastPos;
        QPointF currentPos;
        uint startTime = 0;
        bool moved = false;
    };
    
    QHash<int, TouchPoint> m_touchPoints;
    QPointF m_pinchCenter;
    qreal m_lastPinchScale = 1.0;
    uint m_longPressTimerId = 0;
    QPointF m_longPressPos;
    int m_longPressTouchId = -1;
    
    // Gesture thresholds
    static constexpr qreal TAP_MAX_DISTANCE = 20.0;
    static constexpr qreal TAP_MAX_TIME = 200; // ms
    static constexpr qreal DOUBLE_TAP_MAX_TIME = 300; // ms
    static constexpr qreal LONG_PRESS_TIME = 500; // ms
    static constexpr qreal SWIPE_MIN_DISTANCE = 50.0;
    static constexpr qreal SWIPE_MIN_VELOCITY = 100.0; // px/s
    static constexpr qreal PINCH_MIN_SCALE_CHANGE = 0.1;
    static constexpr qreal EDGE_SWIPE_THRESHOLD = 20.0; // px from edge
    static constexpr qreal EDGE_SWIPE_ACTIVATION = 0.8; // progress threshold
    
    uint m_lastTapTime = 0;
    QPointF m_lastTapPos;
    
    void processTouchBegin(QTouchEvent *event);
    void processTouchUpdate(QTouchEvent *event);
    void processTouchEnd(QTouchEvent *event);
    void processTouchCancel(QTouchEvent *event);
    
    void checkGestures();
    void detectTap(const TouchPoint &point);
    void detectDoubleTap(const TouchPoint &point);
    void detectLongPress();
    void detectSwipe(const TouchPoint &point);
    void detectPinch(QTouchEvent *event);
    void detectEdgeSwipe(const TouchPoint &point);
    void detectThreeFingerGestures();
    
    void emitGestureStarted(const GestureEvent &event);
    void emitGestureUpdated(const GestureEvent &event);
    void emitGestureEnded(const GestureEvent &event);
    void emitGestureCancelled(const GestureEvent &event);
    
    void startLongPressTimer(int touchId, const QPointF &pos);
    void stopLongPressTimer();
    
    Edge getEdgeFromPosition(const QPointF &pos) const;
    bool isNearEdge(const QPointF &pos, Edge edge) const;
    qreal getEdgeProgress(const QPointF &pos, Edge edge) const;
};