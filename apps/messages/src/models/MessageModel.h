#pragma once

#include <QAbstractListModel>
#include <QDateTime>

struct MessageInfo {
    QString id;
    QString conversationId;
    QString senderId;
    QString senderName;
    QString senderNumber;
    QString body;
    enum class MessageType { Text, Image, Video, Audio, File, Location, Contact, Sticker, System } type;
    enum class MessageStatus { Sending, Sent, Delivered, Read, Failed } status;
    QDateTime timestamp;
    QDateTime deliveredTime;
    QDateTime readTime;
    QString mediaUrl;
    QString mimeType;
    int size = 0;
    bool isFromMe = false;
    bool isRead = false;
    bool isDelivered = false;
    QString replyToId;
    QStringList reactions;
};

class MessageModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ConversationIdRole,
        SenderIdRole,
        SenderNameRole,
        SenderNumberRole,
        BodyRole,
        TypeRole,
        StatusRole,
        TimestampRole,
        DeliveredTimeRole,
        ReadTimeRole,
        MediaUrlRole,
        MimeTypeRole,
        SizeRole,
        IsFromMeRole,
        IsReadRole,
        IsDeliveredRole,
        ReplyToIdRole,
        ReactionsRole
    };

    explicit MessageModel(QObject *parent = nullptr);
    ~MessageModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE int indexOf(const QString &messageId) const;

    bool loadMessages();
    void refresh();
    void addMessage(const QString &conversationId, const QString &body);

signals:
    void countChanged();
    void messageAdded(const QString &id);
    void messageUpdated(const QString &id);
    void messageRemoved(const QString &messageId);

private:
    struct MessageInfo {
        QString id;
        QString conversationId;
        QString senderId;
        QString senderName;
        QString senderNumber;
        QString body;
        enum class MessageType { Text, Image, Video, Audio, File, Location, Contact, Sticker, System } type;
        enum class MessageStatus { Sending, Sent, Delivered, Read, Failed } status;
        QDateTime timestamp;
        QDateTime deliveredTime;
        QDateTime readTime;
        QString mediaUrl;
        QString mimeType;
        int size = 0;
        bool isFromMe = false;
        bool isRead = false;
        bool isDelivered = false;
        QString replyToId;
        QStringList reactions;
    };

    QList<QVariantMap> m_messages;

    void loadFromDatabase();
    void saveToDatabase();
    QString generateMessageId() const;
};