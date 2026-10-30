#pragma once

#include <QObject>
#include <QQuickItem>

class W10MCommandBar : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged)
    Q_PROPERTY(QQmlListProperty<QObject> primaryCommands READ primaryCommands NOTIFY primaryCommandsChanged)
    Q_PROPERTY(QQmlListProperty<QObject> secondaryCommands READ secondaryCommands NOTIFY secondaryCommandsChanged)
    Q_PROPERTY(QString overflowButtonTooltip READ overflowButtonTooltip WRITE setOverflowButtonTooltip NOTIFY overflowButtonTooltipChanged)
    Q_PROPERTY(bool isOpen READ isOpen WRITE setIsOpen NOTIFY isOpenChanged)
    Q_PROPERTY(bool isCompact READ isCompact WRITE setIsCompact NOTIFY isCompactChanged)
    Q_PROPERTY(bool isSticky READ isSticky WRITE setIsSticky NOTIFY isStickyChanged)
    Q_PROPERTY(QString defaultLabelPosition READ defaultLabelPosition WRITE setDefaultLabelPosition NOTIFY defaultLabelPositionChanged)

public:
    enum DefaultLabelPosition {
        Default,
        Bottom,
        Right,
        Collapsed
    };
    Q_ENUM(DefaultLabelPosition)

    explicit W10MCommandBar(QQuickItem *parent = nullptr);
    ~W10MCommandBar() override;

    QString label() const { return m_label; }
    void setLabel(const QString &label);

    QQmlListProperty<QObject> primaryCommands();
    void appendPrimaryCommand(QObject *command);

    QQmlListProperty<QObject> secondaryCommands();
    void appendSecondaryCommand(QObject *command);

    QString overflowButtonTooltip() const { return m_overflowButtonTooltip; }
    void setOverflowButtonTooltip(const QString &tooltip);

    bool isOpen() const { return m_isOpen; }
    void setOpen(bool open);

    bool isCompact() const { return m_isCompact; }
    void setIsCompact(bool compact);

    bool isSticky() const { return m_isSticky; }
    void setIsSticky(bool sticky);

    QString defaultLabelPosition() const { return m_defaultLabelPosition; }
    void setDefaultLabelPosition(const QString &position);

signals:
    void labelChanged(const QString &label);
    void primaryCommandsChanged();
    void secondaryCommandsChanged();
    void overflowButtonTooltipChanged(const QString &tooltip);
    void openChanged(bool open);
    void isCompactChanged(bool compact);
    void isStickyChanged(bool sticky);
    void defaultLabelPositionChanged(const QString &position);
    void closed();
    void opened();

private:
    QString m_label;
    QList<QObject*> m_primaryCommands;
    QList<QObject*> m_secondaryCommands;
    QString m_overflowButtonTooltip;
    bool m_isOpen = false;
    bool m_isCompact = false;
    bool m_isSticky = false;
    QString m_defaultLabelPosition = "Default";

    static QObject* append_action(QQmlListProperty<QObject> *list, QObject *command);
    static QObject* command_at(QQmlListProperty<QObject> *list, int index);
    static int count_commands(QQmlListProperty<QObject> *list);
    static void clear_commands(QQmlListProperty<QObject> *list);
};