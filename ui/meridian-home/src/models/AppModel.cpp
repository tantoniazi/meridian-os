#include "AppModel.h"
#include <QStandardPaths>
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QProcess>
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>

AppModel::AppModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames[IdRole] = "appId";
    m_roleNames[NameRole] = "name";
    m_roleNames[GenericNameRole] = "genericName";
    m_roleNames[CommentRole] = "comment";
    m_roleNames[IconRole] = "icon";
    m_roleNames[ExecRole] = "exec";
    m_roleNames[CategoriesRole] = "categories";
    m_roleNames[TerminalRole] = "terminal";
    m_roleNames[NoDisplayRole] = "noDisplay";
    m_roleNames[DesktopFileRole] = "desktopFile";
}

AppModel::~AppModel() = default;

int AppModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_applications.size();
}

QVariant AppModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_applications.size())
        return QVariant();

    const AppInfo &app = m_applications[index.row()];

    switch (role) {
    case IdRole:
        return app.id;
    case NameRole:
        return app.name;
    case GenericNameRole:
        return app.genericName;
    case CommentRole:
        return app.comment;
    case IconRole:
        return findIcon(app.icon);
    case ExecRole:
        return app.exec;
    case CategoriesRole:
        return app.categories;
    case TerminalRole:
        return app.terminal;
    case NoDisplayRole:
        return app.noDisplay;
    case DesktopFileRole:
        return app.desktopFile;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AppModel::roleNames() const
{
    return m_roleNames;
}

QVariantMap AppModel::get(int index) const
{
    if (index < 0 || index >= m_applications.size())
        return QVariantMap();

    const AppInfo &app = m_applications[index];
    QVariantMap map;
    map["id"] = app.id;
    map["name"] = app.name;
    map["genericName"] = app.genericName;
    map["comment"] = app.comment;
    map["icon"] = findIcon(app.icon);
    map["exec"] = app.exec;
    map["categories"] = app.categories;
    map["terminal"] = app.terminal;
    map["noDisplay"] = app.noDisplay;
    map["isFavorite"] = m_favorites.contains(app.id);
    return map;
}

void AppModel::launch(int index)
{
    if (index < 0 || index >= m_applications.size())
        return;

    const AppInfo &app = m_applications[index];
    
    QString exec = app.exec;
    exec.remove(QRegularExpression("%[fFuUi%kc]"));
    
    QProcess::startDetached(exec);
}

void AppModel::addFavorite(int index)
{
    if (index < 0 || index >= m_applications.size())
        return;

    const QString &id = m_applications[index].id;
    if (!m_favorites.contains(id)) {
        m_favorites.append(id);
        saveFavorites();
        emit dataChanged(index(index, 0), index(index, 0), {IdRole, NameRole});
    }
}

void AppModel::removeFavorite(int index)
{
    if (index < 0 || index >= m_applications.size())
        return;

    const QString &id = m_applications[index].id;
    if (m_favorites.removeOne(id)) {
        saveFavorites();
        emit dataChanged(index(index, 0), index(index, 0), {IdRole, NameRole});
    }
}

bool AppModel::isFavorite(int index) const
{
    if (index < 0 || index >= m_applications.size())
        return false;
    return m_favorites.contains(m_applications[index].id);
}

int AppModel::indexOf(const QString &appId) const
{
    for (int i = 0; i < m_applications.size(); ++i) {
        if (m_applications[i].id == appId)
            return i;
    }
    return -1;
}

bool AppModel::loadApplications()
{
    beginResetModel();
    m_applications.clear();

    QStringList desktopDirs = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
    desktopDirs << "/var/lib/flatpak/exports/share/applications";
    desktopDirs << QDir::homePath() + "/.local/share/flatpak/exports/share/applications";
    desktopDirs << "/usr/share/meridian/applications";

    for (const QString &dir : desktopDirs) {
        loadDesktopFiles(dir);
    }

    std::sort(m_applications.begin(), m_applications.end(),
              [](const AppInfo &a, const AppInfo &b) {
                  return a.name.toLower() < b.name.toLower();
              });

    loadFavorites();

    endResetModel();
    emit countChanged();
    
    qInfo() << "Loaded" << m_applications.size() << "applications";
    return true;
}

void AppModel::refresh()
{
    loadApplications();
}

void AppModel::loadDesktopFiles(const QString &dirPath)
{
    QDir dir(dirPath);
    if (!dir.exists()) return;

    QStringList filters;
    filters << "*.desktop";
    
    QFileInfoList files = dir.entryInfoList(filters, QDir::Files | QDir::NoDotAndDotDot);
    
    for (const QFileInfo &fileInfo : files) {
        parseDesktopFile(fileInfo.absoluteFilePath());
    }
    
    QStringList subDirs = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &subDir : subDirs) {
        loadDesktopFiles(dirPath + "/" + subDir);
    }
}

void AppModel::parseDesktopFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    AppInfo info;
    info.desktopFile = filePath;
    
    QFileInfo fi(filePath);
    info.id = fi.baseName();

    QTextStream in(&file);
    bool inDesktopEntry = false;
    
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        
        if (line == "[Desktop Entry]") {
            inDesktopEntry = true;
            continue;
        }
        
        if (line.startsWith("[")) {
            inDesktopEntry = false;
            continue;
        }
        
        if (!inDesktopEntry) continue;
        
        if (line.startsWith("Name=")) {
            info.name = line.mid(5);
        } else if (line.startsWith("GenericName=")) {
            info.genericName = line.mid(12);
        } else if (line.startsWith("Comment=")) {
            info.comment = line.mid(8);
        } else if (line.startsWith("Icon=")) {
            info.icon = line.mid(5);
        } else if (line.startsWith("Exec=")) {
            info.exec = line.mid(5);
        } else if (line.startsWith("Categories=")) {
            info.categories = line.mid(11).split(";", Qt::SkipEmptyParts);
        } else if (line.startsWith("Terminal=")) {
            info.terminal = line.mid(9).toLower() == "true";
        } else if (line.startsWith("NoDisplay=")) {
            info.noDisplay = line.mid(10).toLower() == "true";
        }
    }
    
    if (isValidApplication(info)) {
        m_applications.append(info);
    }
}

bool AppModel::isValidApplication(const AppInfo &info) const
{
    return !info.id.isEmpty() && 
           !info.name.isEmpty() && 
           !info.exec.isEmpty() && 
           !info.noDisplay;
}

void AppModel::loadFavorites()
{
    QSettings settings("MeridianOS", "Home");
    m_favorites = settings.value("favorites").toStringList();
}

void AppModel::saveFavorites()
{
    QSettings settings("MeridianOS", "Home");
    settings.setValue("favorites", m_favorites);
}

QString AppModel::findIcon(const QString &iconName) const
{
    if (iconName.isEmpty())
        return QString();
    
    if (iconName.startsWith("/"))
        return iconName;
    
    QIcon icon = QIcon::fromTheme(iconName);
    if (!icon.isNull())
        return iconName;
    
    QStringList iconDirs = QStandardPaths::standardLocations(QStandardPaths::IconsLocation);
    QStringList extensions = {".svg", ".png", ".xpm"};
    
    for (const QString &dir : iconDirs) {
        for (const QString &ext : extensions) {
            QString path = dir + "/" + iconName + ext;
            if (QFile::exists(path))
                return path;
        }
    }
    
    return iconName;
}

void AppModel::launch(int index)
{
    if (index < 0 || index >= m_applications.size())
        return;

    const AppInfo &app = m_applications[index];
    
    QString exec = app.exec;
    exec.remove(QRegularExpression("%[fFuUi%kc]"));
    
    QProcess::startDetached(exec);
}

void AppModel::addFavorite(int index)
{
    if (index < 0 || index >= m_applications.size())
        return;

    const QString &id = m_applications[index].id;
    if (!m_favorites.contains(id)) {
        m_favorites.append(id);
        saveFavorites();
        emit dataChanged(index(index, 0), index(index, 0), {IdRole, NameRole});
    }
}

void AppModel::removeFavorite(int index)
{
    if (index < 0 || index >= m_applications.size())
        return;

    const QString &id = m_applications[index].id;
    if (m_favorites.removeOne(id)) {
        saveFavorites();
        emit dataChanged(index(index, 0), index(index, 0), {IdRole, NameRole});
    }
}

bool AppModel::isFavorite(int index) const
{
    if (index < 0 || index >= m_applications.size())
        return false;
    return m_favorites.contains(m_applications[index].id);
}

int AppModel::indexOf(const QString &appId) const
{
    for (int i = 0; i < m_applications.size(); ++i) {
        if (m_applications[i].id == appId)
            return i;
    }
    return -1;
}