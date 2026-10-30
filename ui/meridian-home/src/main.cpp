#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>
#include <QCommandLineParser>
#include <QStandardPaths>
#include <QDir>

#include "HomeApplication.h"
#include "models/AppModel.h"
#include "models/WidgetModel.h"
#include "models/SettingsModel.h"
#include "views/MainView.h"
#include "views/AppGridView.h"
#include "views/AppDrawerView.h"
#include "views/WidgetSidebar.h"
#include "views/SearchView.h"
#include "views/SettingsView.h"

Q_LOGGING_CATEGORY(meridianHome, "meridian.home")

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
    app.setApplicationName("Meridian Home");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Meridian OS");
    app.setOrganizationDomain("meridian-os.org");

    QCommandLineParser parser;
    parser.setApplicationDescription("Meridian Home - Adaptive Home Screen");
    parser.addHelpOption();
    parser.addVersionOption();
    
    parser.process(app);

    // Register QML types
    qmlRegisterType<AppModel>("Meridian.Home", 1, 0, "AppModel");
    qmlRegisterType<WidgetModel>("Meridian.Home", 1, 0, "WidgetModel");
    qmlRegisterType<SettingsModel>("Meridian.Home", 1, 0, "SettingsModel");
    qmlRegisterType<MainView>("Meridian.Home", 1, 0, "MainView");
    qmlRegisterType<AppGridView>("Meridian.Home", 1, 0, "AppGridView");
    qmlRegisterType<AppDrawerView>("Meridian.Home", 1, 0, "AppDrawerView");
    qmlRegisterType<WidgetSidebar>("Meridian.Home", 1, 0, "WidgetSidebar");
    qmlRegisterType<SearchView>("Meridian.Home", 1, 0, "SearchView");
    qmlRegisterType<SettingsView>("Meridian.Home", 1, 0, "SettingsView");

    // Create home application
    HomeApplication homeApp;
    
    if (!homeApp.initialize()) {
        qCritical() << "Failed to initialize Meridian Home";
        return 1;
    }

    // Create QML engine
    QQmlApplicationEngine engine;
    
    // Register context properties
    engine.rootContext()->setContextProperty("homeApp", &homeApp);
    engine.rootContext()->setContextProperty("appModel", homeApp.appModel());
    engine.rootContext()->setContextProperty("widgetModel", homeApp.widgetModel());
    engine.rootContext()->setContextProperty("settingsModel", homeApp.settingsModel());

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