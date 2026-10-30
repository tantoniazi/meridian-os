#pragma once

#include <QObject>
#include <QScreen>
#include <QRect>
#include <memory>

class W10MCompositor : public QObject
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

    explicit W10MCompositor(QObject *parent = nullptr);
    ~W10MCompositor() override;

    bool initialize();
    
    ShellMode shellMode() const { return m_shellMode; }
    void setShellMode(ShellMode mode);

    Q_INVOKABLE void addOutput(QScreen *screen);
    Q_INVOKABLE void removeOutput(QScreen *screen);
    Q_INVOKABLE void setOutputMode(QScreen *screen, const QSize &size, qreal scale);

signals:
    void shellModeChanged(ShellMode mode);
    void outputAdded(QScreen *screen);
    void outputRemoved(QScreen *screen);
    void outputModeChanged(QScreen *screen, const QSize &size, qreal scale);

private:
    ShellMode m_shellMode = PhoneMode;
    
    class Private;
    std::unique_ptr<Private> d;
    
    void initializeWayland();
    void setupOutputs();
    void setupShell();
};