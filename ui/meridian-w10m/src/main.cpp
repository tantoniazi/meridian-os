#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSurfaceFormat>
#include <QCommandLineParser>
#include <QStandardPaths>
#include <QDir>

#include "src/shell/W10MShell.h"
#include "src/models/W10MAppModel.h"
#include "src/models/W10MTileModel.h"
#include "src/models/W10MSettingsModel.h"

Q_LOGGING_CATEGORY(meridianW10M, "meridian.w10m")

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    
    QSurfaceFormat format;
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    format.setVersion(3, 2);
    format.setProfile(QSurfaceFormat::CoreProfile);
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);

    QGuiApplication app(argc, argv);
    app.setApplicationName("Meridian W10M");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Meridian OS");
    app.setOrganizationDomain("meridian-os.org");

    QCommandLineParser parser;
    parser.setApplicationDescription("Meridian W10M - Windows 10 Mobile Style Interface");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);

    // Register QML types
    qmlRegisterType<W10MAppModel>("Meridian.W10M", 1, 0, "W10MAppModel");
    qmlRegisterType<W10MTileModel>("Meridian.W10M", 1, 0, "W10MTileModel");
    qmlRegisterType<W10MSettingsModel>("Meridian.W10M", 1, 0, "W10MSettingsModel");

    // Create W10M shell
    W10MShell shell;
    
    if (!shell.initialize()) {
        qCritical() << "Failed to initialize Meridian W10M Shell";
        return 1;
    }

    // Create QML engine
    QQmlApplicationEngine engine;
    
    // Register context properties
    engine.rootContext()->setContextProperty("w10mShell", &shell);
    engine.rootContext()->setContextProperty("appModel", shell.appModel());
    engine.rootContext()->setContextProperty("tileModel", shell.tileModel());
    engine.rootContext()->setContextProperty("settingsModel", shell.settingsModel());

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