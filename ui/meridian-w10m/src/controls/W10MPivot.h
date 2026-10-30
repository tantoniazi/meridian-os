#pragma once

#include <QObject>
#include <QQuickItem>

class W10MPivot : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QQmlListProperty<QObject> items READ items NOTIFY itemsChanged)
    Q_PROPERTY(int selectedIndex READ selectedIndex WRITE setSelectedIndex NOTIFY selectedIndexChanged)
    Q_PROPERTY(bool locked READ locked WRITE setLocked NOTIFY lockedChanged)
    Q_PROPERTY(bool animateSelection READ animateSelection WRITE setAnimateSelection NOTIFY animateSelectionChanged)

public:
    explicit W10MPivot(QQuickItem *parent = nullptr);
    ~W10MPivot() override;

    QString title() const { return m_title; }
    void setTitle(const QString &title);

    QQmlListProperty<QObject> items();
    void appendItem(QObject *item);

    int selectedIndex() const { return m_selectedIndex; }
    void setSelectedIndex(int index);

    bool locked() const { return m_locked; }
    void setLocked(bool locked);

    bool animateSelection() const { return m_animateSelection; }
    void setAnimateSelection(bool animate);

signals:
    void titleChanged(const QString &title);
    void itemsChanged();
    void selectedIndexChanged(int index);
    void lockedChanged(bool locked);
    void animateSelectionChanged(bool animate);
    void selectionChanged(int index);

private:
    QString m_title;
    QList<QObject*> m_items;
    int m_selectedIndex = 0;
    bool m_locked = false;
    bool m_animateSelection = true;

    static QObject* append_item(QQmlListProperty<QObject> *list, QObject *item);
    static QObject* item_at(QQmlListProperty<QObject> *list, int index);
    static int count_items(QQmlListProperty<QObject> *list);
    static void clear_items(QQmlListProperty<QObject> *list);
};