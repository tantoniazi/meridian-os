#include "W10MCompositor.h"
#include <QScreen>
#include <QGuiApplication>
#include <QDebug>
#include <QWaylandCompositor>
#include <QWaylandOutput>
#include <QWaylandSurface>
#include <private/qwaylandcompositor_p.h>

class W10MCompositor::Private
{
public:
    QWaylandCompositor *compositor = nullptr;
    QList<QWaylandOutput*> outputs;
};

W10MCompositor::W10MCompositor(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<Private>())
{
}

W10MCompositor::~W10MCompositor() = default;

bool W10MCompositor::initialize()
{
    qInfo() << "Initializing W10M Compositor...";
    
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
    
    // Initialize Wayland compositor
    if (!d->compositor->create()) {
        qCritical() << "Failed to create Wayland compositor";
        return false;
    }
    
    // Set default surface format for Wayland
    QSurfaceFormat::setDefaultFormat(format);
    
    // Set up default surface format for Wayland surfaces
    d->compositor->setDefaultSurfaceFormat(format);
    
    qInfo() << "Wayland compositor initialized";
    
    setupOutputs();
    setupShell();
    
    return true;
}

void W10MCompositor::setupOutputs()
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

void W10MCompositor::setupShell()
{
    // Set up the shell interface (xdg-shell, etc.)
    // This would typically involve setting up xdg-shell, layer-shell, etc.
    qInfo() << "W10M Shell interface initialized";
}

void W10MCompositor::addOutput(QScreen *screen)
{
    if (!screen) return;
    
    qInfo() << "Adding output:" << screen->name() << screen->geometry();
    
    QWaylandOutput *output = new QWaylandOutput(d->compositor, this);
    output->setScreen(screen);
    
    // Set output properties
    output->setMode(screen->preferredGeometry());
    output->setLogicalDpi(screen->logicalDotsPerInch());
    output->setScale(screen->devicePixelRatio());
    
    d->outputs.append(output);
    
    emit outputAdded(screen);
}

void W10MCompositor::removeOutput(QScreen *screen)
{
    if (!screen) return;
    
    for (int i = 0; i < d->outputs.size(); ++i) {
        if (d->outputs[i]->screen() == screen) {
            QWaylandOutput *output = d->outputs.takeAt(i);
            output->deleteLater();
            break;
        }
    }
    
    emit outputRemoved(screen);
}

void W10MCompositor::setOutputMode(QScreen *screen, const QSize &size, qreal scale)
{
    for (QWaylandOutput *output : d->outputs) {
        if (output->screen() == screen) {
            output->setMode(QRect(QPoint(0, 0), size));
            output->setScale(scale);
            emit outputModeChanged(screen, size, scale);
            break;
        }
    }
}

W10MCompositor::ShellMode W10MCompositor::shellMode() const
{
    return m_shellMode;
}

void W10MCompositor::setShellMode(ShellMode mode)
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