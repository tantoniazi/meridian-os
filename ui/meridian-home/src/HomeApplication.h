#pragma once

#include <QObject>
#include <QAbstractListModel>
#include <QSettings>

class AppModel;
class WidgetModel;
class SettingsModel;

class HomeApplication : public QObject
{
    Q_OBJECT
    Q_PROPERTY(AppModel* appModel READ appModel CONSTANT)
    Q_PROPERTY(WidgetModel* widgetModel READ widgetModel CONSTANT)
    Q_PROPERTY(SettingsModel* settingsModel READ settingsModel CONSTANT)

public:
    explicit HomeApplication(QObject *parent = nullptr);
    ~HomeApplication() override;

    bool initialize();

    AppModel* appModel() const { return m_appModel; }
    WidgetModel* widgetModel() const { return m_widgetModel; }
    SettingsModel* settingsModel() const { return m_settingsModel; }

private:
    std::unique_ptr<AppModel> m_appModel;
    std::unique_ptr<WidgetModel> m_widgetModel;
    std::unique_ptr<SettingsModel> m_settingsModel;
    std::unique_ptr<QSettings> m_settings;
};