#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSurfaceFormat>
#include <QCommandLineParser>
#include <QStandardPaths>

#include "MessagesApplication.h"
#include "models/ConversationModel.h"
#include "models/MessageModel.h"
#include "models/ContactModel.h"
#include "controllers/MessageController.h"
#include "controllers/ConversationController.h"

Q_LOGGING_CATEGORY(meridianMessages, "meridian.messages")

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
    app.setApplicationName("Meridian Messages");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Meridian OS");
    app.setOrganizationDomain("meridian-os.org");

    QCommandLineParser parser;
    parser.setApplicationDescription("Meridian Messages - SMS/MMS/RCS messaging");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);

    // Register QML types
    qmlRegisterType<ConversationModel>("Meridian.Messages", 1, 0, "ConversationModel");
    qmlRegisterType<MessageModel>("Meridian.Messages", 1, 0, "MessageModel");
    qmlRegisterType<ContactModel>("Meridian.Messages", 1, 0, "ContactModel");
    qmlRegisterType<MessageController>("Meridian.Messages", 1, 0, "MessageController");
    qmlRegisterType<ConversationController>("Meridian.Messages", 1, 0, "ConversationController");

    // Create messages application
    MessagesApplication messagesApp;
    
    if (!messagesApp.initialize()) {
        qCritical() << "Failed to initialize Meridian Messages";
        return 1;
    }

    // Create QML engine
    QQmlApplicationEngine engine;
    
    // Register context properties
    engine.rootContext()->setContextProperty("messagesApp", &messagesApp);
    engine.rootContext()->setContextProperty("conversationModel", messagesApp.conversationModel());
    engine.rootContext()->setContextProperty("messageModel", messagesApp.messageModel());
    engine.rootContext()->setContextProperty("contactModel", messagesApp.contactModel());
    engine.rootContext()->setContextProperty("messageController", messagesApp.messageController());
    engine.rootContext()->setContextProperty("conversationController", messagesApp.conversationController());

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