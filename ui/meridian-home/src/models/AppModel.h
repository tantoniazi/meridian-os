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
};

class AppModel : public QAbstractListModel
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
        DesktopFileRole
    };

    explicit AppModel(QObject *parent = nullptr);
    ~AppModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void launch(int index);
    Q_INVOKABLE void addFavorite(int index);
    Q_INVOKABLE void removeFavorite(int index);
    Q_INVOKABLE bool isFavorite(int index) const;
    Q_INVOKABLE int indexOf(const QString &appId) const;

    bool loadApplications();
    void refresh();

signals:
    void countChanged();
    void dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = {}) override;

private:
    QList<AppInfo> m_applications;
    QStringList m_favorites;
    QMimeDatabase m_mimeDatabase;

    void loadDesktopFiles(const QString &dirPath);
    void parseDesktopFile(const QString &filePath);
    bool isValidApplication(const AppInfo &info) const;
    void loadFavorites();
    void saveFavorites();
    QString findIcon(const QString &iconName) const;
};