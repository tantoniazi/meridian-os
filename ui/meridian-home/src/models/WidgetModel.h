#pragma once

#include <QAbstractListModel>
#include <QSettings>

struct WidgetInfo {
    QString id;
    QString name;
    QString description;
    QString icon;
    QString qmlPath;
    QSize defaultSize;
    QStringList categories;
    bool resizable = true;
    bool removable = true;
};

class WidgetModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        DescriptionRole,
        IconRole,
        QmlPathRole,
        DefaultSizeRole,
        CategoriesRole,
        ResizableRole,
        RemovableRole
    };

    explicit WidgetModel(QObject *parent = nullptr);
    ~WidgetModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE int indexOf(const QString &widgetId) const;

    bool loadWidgets();
    void refresh();

signals:
    void countChanged();
    void dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = {}) override;

private:
    QList<WidgetInfo> m_widgets;

    void loadBuiltinWidgets();
    void loadExternalWidgets();
    bool isValidWidget(const WidgetInfo &info) const;
};