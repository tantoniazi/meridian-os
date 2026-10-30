#pragma once

#include <QObject>
#include <QEasingCurve>
#include <QPropertyAnimation>
#include <QParallelAnimationGroup>
#include <QSequentialAnimationGroup>

class W10MAnimationManager : public QObject
{
    Q_OBJECT

public:
    explicit W10MAnimationManager(QObject *parent = nullptr);
    ~W10MAnimationManager() override;

    void initialize();

    // Page transitions
    QPropertyAnimation* createPageTransition(QObject *target, const QByteArray &property, 
                                             const QVariant &from, const QVariant &to, 
                                             int duration = 300, 
                                             QEasingCurve::Type easing = QEasingCurve::OutCubic);

    // Entrance animations
    QPropertyAnimation* createEntranceAnimation(QObject *target, const QByteArray &property,
                                                const QVariant &from, const QVariant &to,
                                                int duration = 400);
    QSequentialAnimationGroup* createStaggeredEntrance(QList<QObject*> targets, 
                                                        const QByteArray &property,
                                                        const QVariant &from, 
                                                        const QVariant &to,
                                                int baseDuration = 300,
                                                int staggerDelay = 50);

    // Theme transition
    QPropertyAnimation* createThemeTransition(QObject *target, 
                                              const QByteArray &property,
                                              const QVariant &from, 
                                              const QVariant &to,
                                              int duration = 300);

    // Page transitions
    QSequentialAnimationGroup* createPageTransition(const QString &direction, 
                                                     QObject *outgoingPage, 
                                                     QObject *incomingPage,
                                                     int duration = 300);

    // Tile flip animation (Windows Phone style)
    QSequentialAnimationGroup* createTileFlipAnimation(QObject *target, 
                                                        bool flipHorizontal = false,
                                                        int duration = 600);

    // Pivot/slide animation
    QPropertyAnimation* createPivotAnimation(QObject *target, 
                                             const QByteArray &property,
                                             const QVariant &from, 
                                             const QVariant &to,
                                             int duration = 300);

    // Content transition
    QPropertyAnimation* createContentTransition(QObject *target,
                                                 const QByteArray &property,
                                                 const QVariant &from, 
                                                 const QVariant &to,
                                                 int duration = 250);

    // Reposition theme transition
    QPropertyAnimation* createRepositionAnimation(QObject *target,
                                                   const QByteArray &property,
                                                   const QVariant &from, 
                                                   const QVariant &to,
                                                   int duration = 350);

    // Theme transition
    QSequentialAnimationGroup* createThemeTransition(QObject *target,
                                                      const QString &fromTheme,
                                                      const QString &toTheme,
                                                      int duration = 500);

    // Get easing curves
    static QEasingCurve standardEaseOut();
    static QEasingCurve standardEaseInOut();
    static QEasingCurve standardEaseIn();
    static QEasingCurve accelerateDecelerate();
    static QEasingCurve decelerate();
    static QEasingCurve accelerate();

    // Motion reduction
    void setReducedMotion(bool enabled);
    bool isReducedMotion() const { return m_reducedMotion; }

private:
    bool m_reducedMotion = false;
};