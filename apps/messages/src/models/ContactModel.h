#pragma once

#include <QAbstractListModel>
#include <QDateTime>

struct ContactInfo {
    QString id;
    QString firstName;
    QString lastName;
    QString displayName;
    QStringList phoneNumbers;
    QStringList emails;
    QString organization;
    QString title;
    QString avatar;
    QString ringtone;
    QStringList groups;
    bool isFavorite = false;
    QDateTime created;
    QDateTime modified;
};

class ContactModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        FirstNameRole,
        LastNameRole,
        DisplayNameRole,
        PhoneNumbersRole,
        EmailsRole,
        OrganizationRole,
        TitleRole,
        AvatarRole,
        RingtoneRole,
        GroupsRole,
        IsFavoriteRole,
        CreatedRole,
        ModifiedRole
    };

    explicit ContactModel(QObject *parent = nullptr);
    ~ContactModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void addContact(const QVariantMap &contact);
    Q_INVOKABLE void updateContact(const QString &id, const QVariantMap &contact);
    Q_INVOKABLE void removeContact(const QString &id);
    Q_INVOKABLE void toggleFavorite(const QString &id);
    Q_INVOKABLE int indexOf(const QString &contactId) const;

    bool loadContacts();
    void refresh();

signals:
    void countChanged();
    void contactAdded(const QVariantMap &contact);
    void contactUpdated(const QVariantMap &contact);
    void contactRemoved(const QString &contactId);

private:
    QList<ContactInfo> m_contacts;

    void loadFromDatabase();
    void saveToDatabase();
    QString generateContactId() const;
};