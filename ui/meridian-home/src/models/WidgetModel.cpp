#include "WidgetModel.h"
#include <QStandardPaths>
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>

WidgetModel::WidgetModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames[IdRole] = "widgetId";
    m_roleNames[NameRole] = "name";
    m_roleNames[DescriptionRole] = "description";
    m_roleNames[IconRole] = "icon";
    m_roleNames[QmlPathRole] = "qmlPath";
    m_roleNames[DefaultSizeRole] = "defaultSize";
    m_roleNames[CategoriesRole] = "categories";
    m_roleNames[ResizableRole] = "resizable";
    m_roleNames[RemovableRole] = "removable";
}

WidgetModel::~WidgetModel() = default;

int WidgetModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_widgets.size();
}

QVariant WidgetModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_widgets.size())
        return QVariant();

    const WidgetInfo &widget = m_widgets[index.row()];

    switch (role) {
    case IdRole:
        return widget.id;
    case NameRole:
        return widget.name;
    case DescriptionRole:
        return widget.description;
    case IconRole:
        return widget.icon;
    case QmlPathRole:
        return widget.qmlPath;
    case DefaultSizeRole:
        return widget.defaultSize;
    case CategoriesRole:
        return widget.categories;
    case ResizableRole:
        return widget.resizable;
    case RemovableRole:
        return widget.removable;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> WidgetModel::roleNames() const
{
    return m_roleNames;
}

QVariantMap WidgetModel::get(int index) const
{
    if (index < 0 || index >= m_widgets.size())
        return QVariantMap();

    const WidgetInfo &widget = m_widgets[index];
    QVariantMap map;
    map["id"] = widget.id;
    map["name"] = widget.name;
    map["description"] = widget.description;
    map["icon"] = widget.icon;
    map["qmlPath"] = widget.qmlPath;
    map["defaultSize"] = widget.defaultSize;
    map["categories"] = widget.categories;
    map["resizable"] = widget.resizable;
    map["removable"] = widget.removable;
    return map;
}

int WidgetModel::indexOf(const QString &widgetId) const
{
    for (int i = 0; i < m_widgets.size(); ++i) {
        if (m_widgets[i].id == widgetId)
            return i;
    }
    return -1;
}

bool WidgetModel::loadWidgets()
{
    beginResetModel();
    m_widgets.clear();

    // Load built-in widgets
    loadBuiltinWidgets();

    // Load external widgets from directories
    QStringList widgetDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    for (const QString &dir : widgetDirs) {
        QString widgetDir = dir + "/meridian/widgets";
        QDir dir(widgetDir);
        if (dir.exists()) {
            QStringList filters;
            filters << "*.json";
            QFileInfoList files = dir.entryInfoList(filters, QDir::Files);
            for (const QFileInfo &fileInfo : files) {
                // Parse widget manifest
                QFile file(fileInfo.absoluteFilePath());
                if (file.open(QIODevice::ReadOnly)) {
                    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
                    if (doc.isObject()) {
                        QJsonObject obj = doc.object();
                        WidgetInfo widget;
                        widget.id = obj["id"].toString();
                        widget.name = obj["name"].toString();
                        widget.description = obj["description"].toString();
                        widget.icon = obj["icon"].toString();
                        widget.qmlPath = obj["qmlPath"].toString();
                        QJsonObject sizeObj = obj["defaultSize"].toObject();
                        widget.defaultSize = QSize(sizeObj["width"].toInt(), sizeObj["height"].toInt());
                        QJsonArray cats = obj["categories"].toArray();
                        for (const QJsonValue &v : cats) {
                            widget.categories.append(v.toString());
                        }
                        widget.resizable = obj["resizable"].toBool(true);
                        widget.removable = obj["removable"].toBool(true);
                        
                        if (isValidWidget(widget)) {
                            m_widgets.append(widget);
                        }
                    }
                }
            }
        }
    }

    endResetModel();
    emit countChanged();
    return true;
}

void WidgetModel::refresh()
{
    loadWidgets();
}

void WidgetModel::loadBuiltinWidgets()
{
    // Clock widget
    WidgetInfo clock;
    clock.id = "clock";
    clock.name = "Clock";
    clock.description = "Digital and analog clock with alarms";
    clock.icon = "preferences-system-time";
    clock.qmlPath = "qrc:/widgets/ClockWidget.qml";
    clock.defaultSize = QSize(200, 200);
    clock.categories = {"time", "utility"};
    m_widgets.append(clock);

    // Weather widget
    WidgetInfo weather;
    weather.id = "weather";
    weather.name = "Weather";
    weather.description = "Current weather and forecast";
    weather.icon = "weather-clear";
    weather.qmlPath = "qrc:/widgets/WeatherWidget.qml";
    weather.defaultSize = QSize(300, 200);
    weather.categories = {"weather", "utility"};
    m_widgets.append(weather);

    // Calendar widget
    WidgetInfo calendar;
    calendar.id = "calendar";
    calendar.name = "Calendar";
    calendar.description = "Monthly calendar with events";
    calendar.icon = "calendar";
    calendar.qmlPath = "qrc:/widgets/CalendarWidget.qml";
    calendar.defaultSize = QSize(300, 300);
    calendar.categories = {"time", "productivity"};
    m_widgets.append(calendar);

    // Music player widget
    WidgetInfo music;
    music.id = "music";
    music.name = "Music";
    music.description = "Music player controls";
    music.icon = "audio-x-generic";
    music.qmlPath = "qrc:/widgets/MusicWidget.qml";
    music.defaultSize = QSize(300, 150);
    music.categories = {"media", "entertainment"};
    m_widgets.append(music);

    // Battery widget
    WidgetInfo battery;
    battery.id = "battery";
    battery.name = "Battery";
    battery.description = "Battery status and power management";
    battery.icon = "battery-full";
    battery.qmlPath = "qrc:/widgets/BatteryWidget.qml";
    battery.defaultSize = QSize(150, 100);
    battery.categories = {"system", "utility"};
    m_widgets.append(battery);

    // Network widget
    WidgetInfo network;
    network.id = "network";
    network.name = "Network";
    network.description = "Network status and connections";
    network.icon = "network-wireless";
    network.qmlPath = "qrc:/widgets/NetworkWidget.qml";
    network.defaultSize = QSize(200, 150);
    network.categories = {"system", "network"};
    m_widgets.append(network);

    // Notes widget
    WidgetInfo notes;
    notes.id = "notes";
    notes.name = "Notes";
    notes.description = "Quick notes and reminders";
    notes.icon = "notes";
    notes.qmlPath = "qrc:/widgets/NotesWidget.qml";
    notes.defaultSize = QSize(300, 200);
    notes.categories = {"productivity"};
    m_widgets.append(notes);
}

void WidgetModel::loadExternalWidgets()
{
    // Implemented in loadWidgets()
}

bool WidgetModel::isValidWidget(const WidgetInfo &info) const
{
    return !info.id.isEmpty() && 
           !info.name.isEmpty() && 
           !info.qmlPath.isEmpty();
}