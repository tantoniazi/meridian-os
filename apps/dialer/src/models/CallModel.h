#pragma once

#include <QAbstractListModel>
#include <QDateTime>

struct CallRecord {
    QString id;
    QString number;
    QString name;
    QString normalizedNumber;
    CallType type;
    CallDirection direction;
    QDateTime startTime;
    QDateTime endTime;
    int duration; // seconds
    bool isMissed;
    bool isRead;
    QString contactId;
};

enum class CallType {
    Voice,
    Video,
    VoIP
};

enum class CallDirection {
    Incoming,
    Outgoing,
    Missed
};

class CallModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int missedCount READ missedCount NOTIFY missedCountChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NumberRole,
        NameRole,
        NormalizedNumberRole,
        TypeRole,
        DirectionRole,
        StartTimeRole,
        EndTimeRole,
        DurationRole,
        IsMissedRole,
        IsReadRole,
        ContactIdRole,
        FormattedDurationRole,
        FormattedTimeRole
    };

    explicit CallModel(QObject *parent = nullptr);
    ~CallModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE int missedCount() const;
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void markAsRead(int index);
    Q_INVOKABLE void markAsUnread(int index);
    Q_INVOKABLE void deleteCall(int index);
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE int indexOf(const QString &callId) const;

    bool loadCalls();
    void refresh();
    void addCall(const CallRecord &call);

signals:
    void countChanged();
    void missedCountChanged();
    void callAdded(const CallRecord &call);
    void callUpdated(const CallRecord &call);
    void callRemoved(const QString &callId);

private:
    QList<CallRecord> m_calls;
    int m_missedCount = 0;

    void loadFromDatabase();
    void saveToDatabase();
    void updateMissedCount();
    QString formatDuration(int seconds) const;
    QString formatTime(const QDateTime &dt) const;
    QString generateCallId() const;
};