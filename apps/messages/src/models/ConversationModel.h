#pragma once

#include <QAbstractListModel>
#include <QDateTime>

struct ConversationInfo {
    QString id;
    QString contactId;
    QString contactName;
    QString contactNumber;
    QString contactAvatar;
    QString lastMessage;
    QDateTime lastMessageTime;
    int unreadCount = 0;
    bool isGroup = false;
    QString groupName;
    QString groupAvatar;
    bool isMuted = false;
    bool isPinned = false;
    int messageCount = 0;
};

class ConversationModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int unreadCount READ unreadCount NOTIFY unreadCountChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ContactIdRole,
        ContactNameRole,
        ContactNumberRole,
        ContactAvatarRole,
        LastMessageRole,
        LastMessageTimeRole,
        UnreadCountRole,
        IsGroupRole,
        GroupNameRole,
        GroupAvatarRole,
        IsMutedRole,
        IsPinnedRole,
        MessageCountRole
    };

    explicit ConversationModel(QObject *parent = nullptr);
    ~ConversationModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE int unreadCount() const;
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void markAsRead(int index);
    Q_INVOKABLE void markAsUnread(int index);
    Q_INVOKABLE void pinConversation(int index);
    Q_INVOKABLE void unpinConversation(int index);
    Q_INVOKABLE void muteConversation(int index);
    Q_INVOKABLE void unmuteConversation(int index);
    Q_INVOKABLE void deleteConversation(int index);
    Q_INVOKABLE void archiveConversation(int index);
    Q_INVOKABLE int indexOf(const QString &conversationId) const;

    bool loadConversations();
    void refresh();

signals:
    void countChanged();
    void unreadCountChanged();
    void conversationAdded(const ConversationInfo &conversation);
    void conversationUpdated(const ConversationInfo &conversation);
    void conversationRemoved(const QString &conversationId);

private:
    QList<ConversationInfo> m_conversations;
    int m_unreadCount = 0;

    void loadFromDatabase();
    void saveToDatabase();
    void updateUnreadCount();
    QString generateConversationId() const;
};