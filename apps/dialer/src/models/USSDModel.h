#pragma once

#include <QAbstractListModel>
#include <QDateTime>

struct USSDSession {
    QString id;
    QString code;
    QString response;
    QString serviceCode;
    USSDState state;
    QDateTime timestamp;
    int sessionId;
};

enum class USSDState {
    Initiated,
    InProgress,
    Completed,
    Failed,
    Timeout
};

class USSDModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        CodeRole,
        ResponseRole,
        ServiceCodeRole,
        StateRole,
        TimestampRole,
        SessionIdRole
    };

    explicit USSDModel(QObject *parent = nullptr);
    ~USSDModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE QVariantMap get(int index) const;

    bool loadUSSDSessions();
    void refresh();
    void addSession(const USSDSession &session);
    void updateSession(const QString &id, const USSDSession &session);
    void removeSession(int index);

signals:
    void countChanged();
    void sessionAdded(const USSDSession &session);
    void sessionUpdated(const USSDSession &session);
    void sessionRemoved(const QString &sessionId);

private:
    QList<USSDSession> m_sessions;

    void loadFromDatabase();
    void saveToDatabase();
    QString generateSessionId() const;
};