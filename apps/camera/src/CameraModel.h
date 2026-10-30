#pragma once

#include <QObject>
#include <QImage>
#include <QSize>

class CameraModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool cameraAvailable READ cameraAvailable NOTIFY cameraAvailableChanged)
    Q_PROPERTY(QStringList availableCameras READ availableCameras NOTIFY availableCamerasChanged)
    Q_PROPERTY(int activeCamera READ activeCamera NOTIFY activeCameraChanged)
    Q_PROPERTY(QSize previewResolution READ previewResolution NOTIFY previewResolutionChanged)
    Q_PROPERTY(QSize captureResolution READ captureResolution NOTIFY captureResolutionChanged)
    Q_PROPERTY(int maxZoom READ maxZoom NOTIFY maxZoomChanged)

public:
    explicit CameraModel(QObject *parent = nullptr);
    ~CameraModel() override;

    bool initialize();

    bool cameraAvailable() const { return m_cameraAvailable; }
    QStringList availableCameras() const { return m_availableCameras; }
    int activeCamera() const { return m_activeCamera; }
    QSize previewResolution() const { return m_previewResolution; }
    QSize captureResolution() const { return m_captureResolution; }
    int maxZoom() const { return m_maxZoom; }

    Q_INVOKABLE bool switchCamera(int cameraId);
    Q_INVOKABLE void setPreviewResolution(const QSize &size);
    Q_INVOKABLE void setCaptureResolution(const QSize &size);
    Q_INVOKABLE void setFocusMode(const QString &mode);
    Q_INVOKABLE void setExposureMode(const QString &mode);
    Q_INVOKABLE void setWhiteBalance(const QString &mode);
    Q_INVOKABLE QImage capturePreviewFrame();

signals:
    void cameraAvailableChanged(bool available);
    void availableCamerasChanged(const QStringList &cameras);
    void activeCameraChanged(int camera);
    void previewResolutionChanged(const QSize &size);
    void captureResolutionChanged(const QSize &size);
    void maxZoomChanged(int zoom);
    void frameReady(const QImage &frame);
    void photoCaptured(const QString &filePath);
    void videoRecordingStarted(const QString &filePath);
    void videoRecordingStopped(const QString &filePath, int duration);
    void errorOccurred(const QString &error);

private:
    bool m_cameraAvailable = false;
    QStringList m_availableCameras;
    int m_activeCamera = 0;
    QSize m_previewResolution = QSize(1280, 720);
    QSize m_captureResolution = QSize(4032, 3024);
    int m_maxZoom = 10;

    void detectCameras();
    void initializeDefaultCamera();
};