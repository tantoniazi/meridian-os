#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSurfaceFormat>
#include <QCommandLineParser>
#include <QStandardPaths>

#include "CameraApplication.h"
#include "CameraController.h"
#include "CameraModel.h"

Q_LOGGING_CATEGORY(meridianCamera, "meridian.camera")

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
    app.setApplicationName("Meridian Camera");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Meridian OS");
    app.setOrganizationDomain("meridian-os.org");

    QCommandLineParser parser;
    parser.setApplicationDescription("Meridian Camera - Photo and video capture");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);

    // Register QML types
    qmlRegisterType<CameraController>("Meridian.Camera", 1, 0, "CameraController");
    qmlRegisterType<CameraModel>("Meridian.Camera", 1, 0, "CameraModel");

    // Create camera application
    CameraApplication cameraApp;
    
    if (!cameraApp.initialize()) {
        qCritical() << "Failed to initialize Meridian Camera";
        return 1;
    }

    // Create QML engine
    QQmlApplicationEngine engine;
    
    // Register context properties
    engine.rootContext()->setContextProperty("cameraApp", &cameraApp);
    engine.rootContext()->setContextProperty("cameraController", cameraApp.cameraController());
    engine.rootContext()->setContextProperty("cameraModel", cameraApp.cameraModel());

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