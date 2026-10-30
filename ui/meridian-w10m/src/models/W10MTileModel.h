#pragma once

#include <QAbstractListModel>
#include <QSize>
#include <QColor>

struct TileInfo {
    QString id;
    QString appId;
    QString title;
    QString description;
    QString icon;
    QString backgroundColor;
    QString foregroundColor;
    TileSize size = TileSize::Medium;
    TileType type = TileType::Static;
    QString liveContent;
    bool isPinned = false;
    int position = 0;
    int row = 0;
    int column = 0;
};

enum class TileSize {
    Small,      // 1x1
    Medium,     // 2x2
    Wide,       // 4x2
    Large       // 4x4
};

enum class TileType {
    Static,      // Static icon
    Live,        // Live tile with dynamic content
    Flip,        // Flip animation (front/back)
    Interactive  // Interactive content
};

class W10MTileModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int columns READ columns WRITE setColumns NOTIFY columnsChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        AppIdRole,
        TitleRole,
        DescriptionRole,
        IconRole,
        BackgroundColorRole,
        ForegroundColorRole,
        SizeRole,
        TypeRole,
        LiveContentRole,
        IsPinnedRole,
        PositionRole,
        RowRole,
        ColumnRole
    };

    explicit W10MTileModel(QObject *parent = nullptr);
    ~W10MTileModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int count() const { return rowCount(); }
    Q_INVOKABLE int columns() const { return m_columns; }
    void setColumns(int columns);

    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE int indexOf(const QString &tileId) const;
    Q_INVOKABLE void addTile(const QString &appId, TileSize size, int row, int column);
    Q_INVOKABLE void removeTile(const QString &tileId);
    Q_INVOKABLE void moveTile(const QString &tileId, int row, int column);
    Q_INVOKABLE void resizeTile(const QString &tileId, TileSize size);
    Q_INVOKABLE void updateLiveContent(const QString &tileId, const QString &content);
    Q_INVOKABLE void pinTile(const QString &tileId);
    Q_INVOKABLE void unpinTile(const QString &tileId);

    bool loadTiles();
    void refresh();

signals:
    void countChanged();
    void columnsChanged(int columns);
    void tileAdded(const TileInfo &tile);
    void tileRemoved(const QString &tileId);
    void tileMoved(const QString &tileId, int row, int column);
    void tileResized(const QString &tileId, int size);
    void liveContentUpdated(const QString &tileId, const QString &content);

private:
    QList<TileInfo> m_tiles;
    int m_columns = 4;
    int m_rows = 6;
    QSettings *m_settings = nullptr;

    void loadTiles();
    void saveTiles();
    void generateDefaultLayout();
    void saveTilesToSettings();
    void loadTilesFromSettings();
    void generateDefaultLayout();
};