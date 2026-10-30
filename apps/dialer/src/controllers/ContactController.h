#pragma once

#include <QObject>

class ContactModel;

class ContactController : public QObject
{
    Q_OBJECT

public:
    explicit ContactController(ContactModel *contactModel, QObject *parent = nullptr);
    ~ContactController() override;

    bool initialize();

    Q_INVOKABLE void addContact(const QVariantMap &contact);
    Q_INVOKABLE void updateContact(const QString &id, const QVariantMap &contact);
    Q_INVOKABLE void removeContact(const QString &id);
    Q_INVOKABLE void toggleFavorite(const QString &id);
    Q_INVOKABLE void callContact(const QString &id);
    Q_INVOKABLE void messageContact(const QString &id);
    Q_INVOKABLE void shareContact(const QString &id);
    Q_INVOKABLE void addToGroup(const QString &id, const QString &group);
    Q_INVOKABLE void removeFromGroup(const QString &id, const QString &group);
    Q_INVOKABLE QVariantMap search(const QString &query) const;
    Q_INVOKABLE QVariantMap getContact(const QString &id) const;

signals:
    void contactAdded(const QVariantMap &contact);
    void contactUpdated(const QVariantMap &contact);
    void contactRemoved(const QString &id);

private:
    ContactModel *m_contactModel = nullptr;
};