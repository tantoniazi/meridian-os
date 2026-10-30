#pragma once

#include <QObject>
#include <QString>

class W10MNavigation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentView READ currentView NOTIFY currentViewChanged)

public:
    explicit W10MNavigation(QObject *parent = nullptr);
    ~W10MNavigation() override;

    bool initialize();
    
    QString currentView() const { return m_currentView; }
    void setCurrentView(const QString &view);

    Q_INVOKABLE void navigateTo(const QString &view);
    Q_INVOKABLE void goBack();
    Q_INVOKABLE void goForward();
    Q_INVOKABLE void goHome();
    Q_INVOKABLE void goToStartScreen();
    Q_INVOKABLE void goToAllApps();
    Q_INVOKABLE void goToActionCenter();
    Q_INVOKABLE void goToSettings();
    Q_INVOKABLE void goToLockScreen();
    Q_INVOKABLE void goToCallView();
    Q_INVOKABLE void goToMessageView();

signals:
    void currentViewChanged(const QString &view);
    void navigateTo(const QString &view);
    void backRequested();
    void forwardRequested();
    void homeRequested();

private:
    QString m_currentView = "start";
    QStringList m_history;
    int m_historyIndex = -1;
    
    void addToHistory(const QString &view);
    void updateCurrentView(const QString &view);
};