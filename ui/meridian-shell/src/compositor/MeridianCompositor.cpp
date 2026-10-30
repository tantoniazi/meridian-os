#include "MeridianCompositor.h"
#include <QScreen>
#include <QGuiApplication>
#include <QDebug>
#include <QWaylandCompositor>
#include <QWaylandOutput>
#include <QWaylandSurface>
#include <QWaylandQuickItem>
#include <private/qwaylandcompositor_p.h>

class MeridianCompositor::Private
{
public:
    QWaylandCompositor *compositor = nullptr;
    QList<QWaylandOutput*> outputs;
};

MeridianCompositor::MeridianCompositor(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<Private>())
{
}

MeridianCompositor::~MeridianCompositor() = default;

bool MeridianCompositor::initialize()
{
    qInfo() << "Initializing Meridian Compositor...";
    
    // Create Wayland compositor
    d->compositor = new QWaylandCompositor(this);
    
    // Set default surface format
    QSurfaceFormat format;
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    format.setVersion(3, 2);
    format.setProfile(QSurfaceFormat::CoreProfile);
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);
    
    // Set up default surface format for Wayland
    QSurfaceFormat::setDefaultFormat(format);
    
    // Initialize Wayland compositor
    if (!d->compositor->create()) {
        qCritical() << "Failed to create Wayland compositor";
        return false;
    }
    
    // Set default surface format for Wayland surfaces
    d->compositor->setDefaultSurfaceFormat(format);
    
    // Set up default cursor
    // cursorTheme = new QCursorTheme("Meridian", 24, this);
    
    qInfo() << "Wayland compositor initialized";
    
    setupOutputs();
    setupShell();
    
    return true;
}

void MeridianCompositor::setupOutputs()
{
    // Get all available screens
    const auto screens = QGuiApplication::screens();
    for (QScreen *screen : screens) {
        addOutput(screen);
    }
    
    // Connect to screen changes
    connect(qGuiApp, &QGuiApplication::screenAdded, this, [this](QScreen *screen) {
        addOutput(screen);
    });
    
    connect(qGuiApp, &QGuiApplication::screenRemoved, this, [this](QScreen *screen) {
        removeOutput(screen);
    });
}

void MeridianCompositor::setupShell()
{
    // Set up the shell interface (xdg-shell, etc.)
    // This would typically involve setting up xdg-shell, layer-shell, etc.
    qInfo() << "Shell interface initialized";
}

void MeridianCompositor::addOutput(QScreen *screen)
{
    if (!screen) return;
    
    qInfo() << "Adding output:" << screen->name() << screen->geometry();
    
    QWaylandOutput *output = new QWaylandOutput(d->compositor, this);
    output->setScreen(screen);
    
    // Set output properties
    output->setMode(screen->preferredGeometry());
    
    // Set logical DPI
    output.setLogicalDpi(screen->logicalDotsPerInch());
    
    // Set scale factor
    output.setScale(screen->devicePixelRatio());
    
    d->outputs.append(output);
    
    emit screenAdded(screen);
}

void MeridianCompositor::removeOutput(QScreen *screen)
{
    if (!screen) return;
    
    for (int i = 0; i < d->outputs.size(); ++i) {
        if (d->outputs[i]->screen() == screen) {
            QWaylandOutput *output = d->outputs.takeAt(i);
            output->deleteLater();
            break;
        }
    }
    
    emit screenRemoved(screen);
}

MeridianCompositor::ShellMode MeridianCompositor::shellMode() const
{
    return m_shellMode;
}

void MeridianCompositor::setShellMode(ShellMode mode)
{
    if (m_shellMode != mode) {
        m_shellMode = mode;
        qInfo() << "Shell mode changed to:" << mode;
        emit shellModeChanged(mode);
        
        // Reconfigure outputs for new mode
        for (QWaylandOutput *output : d->outputs) {
            // Reconfigure output for new shell mode
        }
    }
}