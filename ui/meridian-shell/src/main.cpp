#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>
#include <QCommandLineParser>
#include <QLoggingCategory>
#include <QStandardPaths>
#include <QDir>

#include "shell/MeridianShell.h"
#include "compositor/MeridianCompositor.h"
#include "input/InputManager.h"
#include "gestures/GestureRecognizer.h"

Q_LOGGING_CATEGORY(meridianShell, "meridian.shell")

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    
    // Set up OpenGL/ES
    QSurfaceFormat format;
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    format.setVersion(3, 2);
    format.setProfile(QSurfaceFormat::CoreProfile);
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);

    QGuiApplication app(argc, argv);
    app.setApplicationName("Meridian Shell");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Meridian OS");
    app.setOrganizationDomain("meridian-os.org");

    // Command line parsing
    QCommandLineParser parser;
    parser.setApplicationDescription("Meridian Shell - Adaptive Wayland Compositor");
    parser.addHelpOption();
    parser.addVersionOption();
    
    QCommandLineOption modeOption(QStringList() << "m" << "mode",
                                  "Shell mode: phone, tablet, desktop", "mode");
    parser.addOption(modeOption);
    
    QCommandLineOption debugOption("debug", "Enable debug logging");
    parser.addOption(debugOption);
    
    parser.process(app);

    if (parser.isSet(debugOption)) {
        QLoggingCategory::setFilterRules("meridian.*=true");
    }

    // Create the shell
    MeridianShell shell;
    
    // Set mode from command line
    if (parser.isSet(modeOption)) {
        QString mode = parser.value(modeOption);
        if (mode == "phone") {
            shell.setMode(MeridianShell::Phone);
        } else if (mode == "tablet") {
            shell.setMode(MeridianShell::Tablet);
        } else if (mode == "desktop") {
            shell.setMode(MeridianShell::Desktop);
        }
    }

    // Initialize the shell
    if (!shell.initialize()) {
        qCritical() << "Failed to initialize Meridian Shell";
        return 1;
    }

    // Create QML engine for UI
    QQmlApplicationEngine engine;
    
    // Register QML types
    qmlRegisterType<MeridianShell>("Meridian.Shell", 1, 0, "MeridianShell");
    qmlRegisterType<InputManager>("Meridian.Input", 1, 0, "InputManager");
    qmlRegisterType<GestureRecognizer>("Meridian.Gestures", 1, 0, "GestureRecognizer");
    
    // Expose shell to QML
    engine.rootContext()->setContextProperty("meridianShell", &shell);
    
    // Load main QML
    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}