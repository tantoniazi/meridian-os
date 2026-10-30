#pragma once

#include <QObject>
#include <QScreen>
#include <QRect>
#include <QPoint>
#include <QSize>
#include <memory>

class W10MAppModel;
class W10MTileModel;
class W10MSettingsModel;
class W10MCompositor;
class W10MNavigation;
class W10MInputManager;
class W10MAnimationManager;

class W10MShell : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ShellMode mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool isActive READ isActive NOTIFY activeChanged)
    Q_PROPERTY(QString currentTheme READ currentTheme WRITE setCurrentTheme NOTIFY themeChanged)

public:
    enum ShellMode {
        PhoneMode,
        TabletMode,
        DesktopMode
    };
    Q_ENUM(ShellMode)

    explicit W10MShell(QObject *parent = nullptr);
    ~W10MShell() override;

    bool initialize();

    ShellMode mode() const { return m_mode; }
    void setMode(ShellMode mode);

    bool isActive() const { return m_active; }

    QString currentTheme() const { return m_currentTheme; }
    void setCurrentTheme(const QString &theme);

    W10MAppModel* appModel() const { return m_appModel.get(); }
    W10MTileModel* tileModel() const { return m_tileModel.get(); }
    W10MSettingsModel* settingsModel() const { return m_settingsModel.get(); }
    W10MCompositor* compositor() const { return m_compositor.get(); }
    W10MNavigation* navigation() const { return m_navigation.get(); }
    W10MInputManager* inputManager() const { return m_inputManager.get(); }
    W10MAnimationManager* animationManager() const { return m_animationManager.get(); }

    Q_INVOKABLE void showStartScreen();
    Q_INVOKABLE void showAllApps();
    Q_INVOKABLE void showActionCenter();
    Q_INVOKABLE void showSettings();
    Q_INVOKABLE void showLockScreen();
    Q_INVOKABLE void showCallView();
    Q_INVOKABLE void showMessageView();

    Q_INVOKABLE void setTheme(const QString &theme);
    Q_INVOKABLE void toggleTheme();

signals:
    void modeChanged(ShellMode mode);
    void activeChanged(bool active);
    void themeChanged(const QString &theme);
    void startScreenRequested();
    void allAppsRequested();
    void actionCenterRequested();
    void settingsRequested();
    void lockScreenRequested();
    void callViewRequested();
    void messageViewRequested();

private:
    ShellMode m_mode = PhoneMode;
    bool m_active = false;
    QString m_currentTheme = "dark";

    std::unique_ptr<W10MAppModel> m_appModel;
    std::unique_ptr<W10MTileModel> m_tileModel;
    std::unique_ptr<W10MSettingsModel> m_settingsModel;
    std::unique_ptr<W10MCompositor> m_compositor;
    std::unique_ptr<W10MNavigation> m_navigation;
    std::unique_ptr<W10MInputManager> m_inputManager;
    std::unique_ptr<W10MAnimationManager> m_animationManager;

    void setupConnections();
    void applyMode();
    void applyTheme();
    void loadConfiguration();
};