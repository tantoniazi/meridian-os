#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSurfaceFormat>
#include <QCommandLineParser>
#include <QStandardPaths>

#include "DialerApplication.h"
#include "models/CallModel.h"
#include "models/ContactModel.h"
#include "models/USSDModel.h"
#include "controllers/CallController.h"
#include "controllers/ContactController.h"
#include "controllers/USSDController.h"

Q_LOGGING_CATEGORY(meridianDialer, "meridian.dialer")

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
    app.setApplicationName("Meridian Dialer");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Meridian OS");
    app.setOrganizationDomain("meridian-os.org");

    QCommandLineParser parser;
    parser.setApplicationDescription("Meridian Dialer - Phone dialer with USSD support");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);

    // Register QML types
    qmlRegisterType<CallModel>("Meridian.Dialer", 1, 0, "CallModel");
    qmlRegisterType<ContactModel>("Meridian.Dialer", 1, 0, "ContactModel");
    qmlRegisterType<USSDModel>("Meridian.Dialer", 1, 0, "USSDModel");
    qmlRegisterType<CallController>("Meridian.Dialer", 1, 0, "CallController");
    qmlRegisterType<ContactController>("Meridian.Dialer", 1, 0, "ContactController");
    qmlRegisterType<USSDController>("Meridian.Dialer", 1, 0, "USSDController");

    // Create dialer application
    DialerApplication dialerApp;
    
    if (!dialerApp.initialize()) {
        qCritical() << "Failed to initialize Meridian Dialer";
        return 1;
    }

    // Create QML engine
    QQmlApplicationEngine engine;
    
    // Register context properties
    engine.rootContext()->setContextProperty("dialerApp", &dialerApp);
    engine.rootContext()->setContextProperty("callModel", dialerApp.callModel());
    engine.rootContext()->setContextProperty("contactModel", dialerApp.contactModel());
    engine.rootContext()->setContextProperty("ussdModel", dialerApp.ussdModel());
    engine.rootContext()->setContextProperty("callController", dialerApp.callController());
    engine.rootContext()->setContextProperty("contactController", dialerApp.contactController());
    engine.rootContext()->setContextProperty("ussdController", dialerApp.ussdController());

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