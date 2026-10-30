#pragma once

#include <QObject>
#include <QTouchEvent>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QHoverEvent>
#include <QWheelEvent>
#include <QTabletEvent>

class W10MInputManager : public QObject
{
    Q_OBJECT

public:
    explicit W10MInputManager(QObject *parent = nullptr);
    ~W10MInputManager() override;

    bool initialize();

    Q_INVOKABLE void processTouchEvent(QTouchEvent *event);
    Q_INVOKABLE void processMouseEvent(QMouseEvent *event);
    Q_INVOKABLE void processKeyEvent(QKeyEvent *event);
    Q_INVOKABLE void processHoverEvent(QHoverEvent *event);
    Q_INVOKABLE void processWheelEvent(QWheelEvent *event);
    Q_INVOKABLE void processTabletEvent(QTabletEvent *event);

signals:
    void touchEvent(QTouchEvent *event);
    void mouseEvent(QMouseEvent *event);
    void keyPressed(Qt::Key key, Qt::KeyboardModifiers modifiers);
    void keyReleased(Qt::Key key, Qt::KeyboardModifiers modifiers);
    void hoverEvent(QHoverEvent *event);
    void wheelEvent(QWheelEvent *event);
    void tabletEvent(QTabletEvent *event);

private:
    bool m_initialized = false;
    bool eventFilter(QObject *watched, QEvent *event);
};