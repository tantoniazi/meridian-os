#pragma once

#include <QObject>
#include <QScreen>
#include <QRect>
#include <QPoint>
#include <QSize>

class MeridianCompositor;
class InputManager;
class GestureRecognizer;

class MeridianShell : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool isActive READ isActive NOTIFY activeChanged)
    Q_PROPERTY(QString currentProfile READ currentProfile WRITE setCurrentProfile NOTIFY profileChanged)

public:
    enum Mode {
        Phone,
        Tablet,
        Desktop
    };
    Q_ENUM(Mode)

    explicit MeridianShell(QObject *parent = nullptr);
    ~MeridianShell() override;

    bool initialize();

    Mode mode() const { return m_mode; }
    void setMode(Mode mode);

    bool isActive() const { return m_active; }

    QString currentProfile() const { return m_currentProfile; }
    void setCurrentProfile(const QString &profile);

    MeridianCompositor* compositor() const { return m_compositor.get(); }
    InputManager* inputManager() const { return m_inputManager.get(); }
    GestureRecognizer* gestureRecognizer() const { return m_gestureRecognizer.get(); }

    Q_INVOKABLE void showHome();
    Q_INVOKABLE void showAppGrid();
    Q_INVOKABLE void showQuickSettings();
    Q_INVOKABLE void showNotifications();
    Q_INVOKABLE void showAppDrawer();
    Q_INVOKABLE void closeAllPanels();

    Q_INVOKABLE void setTheme(const QString &theme);
    Q_INVOKABLE void toggleTheme();

signals:
    void modeChanged(Mode mode);
    void activeChanged(bool active);
    void profileChanged(const QString &profile);
    void homeRequested();
    void appGridRequested();
    void quickSettingsRequested();
    void notificationsRequested();
    void appDrawerRequested();

private:
    Mode m_mode = Phone;
    bool m_active = false;
    QString m_currentProfile = "balanced";

    std::unique_ptr<MeridianCompositor> m_compositor;
    std::unique_ptr<InputManager> m_inputManager;
    std::unique_ptr<GestureRecognizer> m_gestureRecognizer;

    void setupConnections();
    void applyMode();
    void loadConfiguration();
};