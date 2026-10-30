#pragma once

#include <QObject>
#include <QQuickItem>

class W10MAppBar : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QQmlListProperty<QObject> actions READ actions NOTIFY actionsChanged)
    Q_PROPERTY(bool isOpen READ isOpen WRITE setOpen NOTIFY openChanged)
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool isCompact READ isCompact WRITE setIsCompact NOTIFY isCompactChanged)

public:
    enum Mode {
        Minimal,
        Compact,
        Full
    };
    Q_ENUM(Mode)

    explicit W10MAppBar(QQuickItem *parent = nullptr);
    ~W10MAppBar() override;

    QString title() const { return m_title; }
    void setTitle(const QString &title);

    QQmlListProperty<QObject> actions();
    void appendAction(QObject *action);

    bool isOpen() const { return m_isOpen; }
    void setOpen(bool open);

    Mode mode() const { return m_mode; }
    void setMode(Mode mode);

    bool isCompact() const { return m_isCompact; }
    void setIsCompact(bool compact);

signals:
    void titleChanged(const QString &title);
    void actionsChanged();
    void openChanged(bool open);
    void modeChanged(Mode mode);
    void isCompactChanged(bool compact);
    void closed();

private:
    QString m_title;
    QList<QObject*> m_actions;
    bool m_isOpen = false;
    Mode m_mode = Full;
    bool m_isCompact = false;
};