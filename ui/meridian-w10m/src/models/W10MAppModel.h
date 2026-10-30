#pragma once

#include <QAbstractListModel>
#include <QStandardPaths>
#include <QDir>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QMimeType>

struct AppInfo {
    QString id;
    QString name;
    QString genericName;
    QString comment;
    QString icon;
    QString exec;
    QStringList categories;
    bool terminal = false;
    bool noDisplay = false;
    QString desktopFile;
    bool isSystemApp = false;
};

class W10MAppModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        GenericNameRole,
        CommentRole,
        IconRole,
        ExecRole,
        CategoriesRole,
        TerminalRole,
        NoDisplayRole,
        DesktopFileRole,
        IsSystemAppRole
    };

    explicit W10MAppModel(QObject *parent = nullptr);
    ~W10MAppModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void launch(int index);
    Q_INVOKABLE void addToStart(const QString &appId);
    Q_INVOKABLE void removeFromStart(const QString &appId);
    Q_INVOKABLE void pinToTaskbar(const QString &appId);
    Q_INVOKABLE void unpinFromTaskbar(const QString &appId);
    Q_INVOKABLE bool isPinned(const QString &appId) const;
    Q_INVOKABLE int indexOf(const QString &appId) const;

    bool loadApplications();
    void refresh();

signals:
    void countChanged();
    void appAdded(const AppInfo &app);
    void appRemoved(const QString &appId);
    void appPinned(const QString &appId);
    void appUnpinned(const QString &appId);

private:
    QList<AppInfo> m_applications;
    QStringList m_pinnedApps;
    QMimeDatabase m_mimeDatabase;

    void loadDesktopFiles(const QString &dirPath);
    void parseDesktopFile(const QString &filePath);
    bool isValidApplication(const AppInfo &info) const;
    void loadPinnedApps();
    void savePinnedApps();
    QString findIcon(const QString &iconName) const;
};