#pragma once

#include <QObject>
#include <QScreen>
#include <QRect>
#include <memory>

class QWaylandCompositor;
class QWaylandSurface;

class MeridianCompositor : public QObject
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

    explicit MeridianCompositor(QObject *parent = nullptr);
    ~MeridianCompositor() override;

    bool initialize();
    
    ShellMode shellMode() const { return m_shellMode; }
    void setShellMode(ShellMode mode);

    Q_INVOKABLE void addOutput(QScreen *screen);
    Q_INVOKABLE void removeOutput(QScreen *screen);

signals:
    void shellModeChanged(ShellMode mode);
    void screenAdded(QScreen *screen);
    void screenRemoved(QScreen *screen);
    void surfaceCreated(QObject *surface);
    void surfaceDestroyed(QObject *surface);

private:
    ShellMode m_shellMode = PhoneMode;
    
    class Private;
    std::unique_ptr<Private> d;
    
    void initializeWayland();
    void setupOutputs();
    void setupShell();
};