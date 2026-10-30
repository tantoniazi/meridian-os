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
    Q_INVOKABLE void addContact(const ContactInfo &contact);
    Q_INVOKABLE void updateContact(const QString &id, const ContactInfo &contact);
    Q_INVOKABLE void removeContact(int index);
    Q_INVOKABLE void toggleFavorite(int index);
    Q_INVOKABLE int indexOf(const QString &contactId) const;
    Q_INVOKABLE QVariantMap search(const QString &query) const;

    bool loadContacts();
    void refresh();
    void importFromVCard(const QString &filePath);
    void exportToVCard(const QString &filePath);

signals:
    void countChanged();
    void contactAdded(const ContactInfo &contact);
    void contactUpdated(const ContactInfo &contact);
    void contactRemoved(const QString &contactId);

private:
    QList<ContactInfo> m_contacts;

    void loadFromDatabase();
    void saveToDatabase();
    void loadFromVCard(const QString &filePath);
    QString generateContactId() const;
};