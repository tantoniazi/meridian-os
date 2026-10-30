#pragma once

#include <QObject>
#include <QTimer>

class CameraModel;

class CameraController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY recordingChanged)
    Q_PROPERTY(bool flashEnabled READ flashEnabled WRITE setFlashEnabled NOTIFY flashEnabledChanged)
    Q_PROPERTY(int zoomLevel READ zoomLevel WRITE setZoomLevel NOTIFY zoomLevelChanged)
    Q_PROPERTY(QString currentMode READ currentMode NOTIFY modeChanged)

public:
    enum CaptureMode {
        Photo,
        Video,
        Portrait,
        Night,
        Panorama,
        SlowMotion,
        TimeLapse
    };
    Q_ENUM(CaptureMode)

    explicit CameraController(CameraModel *cameraModel, QObject *parent = nullptr);
    ~CameraController() override;

    bool initialize();

    bool isRecording() const { return m_isRecording; }
    bool flashEnabled() const { return m_flashEnabled; }
    int zoomLevel() const { return m_zoomLevel; }
    QString currentMode() const { return m_currentMode; }

    Q_INVOKABLE void takePhoto();
    Q_INVOKABLE void startVideoRecording();
    Q_INVOKABLE void stopVideoRecording();
    Q_INVOKABLE void toggleFlash();
    Q_INVOKABLE void setFlashEnabled(bool enabled);
    Q_INVOKABLE void zoomIn();
    Q_INVOKABLE void zoomOut();
    Q_INVOKABLE void setZoomLevel(int level);
    Q_INVOKABLE void switchCamera(int cameraId);
    Q_INVOKABLE void setCaptureMode(CaptureMode mode);
    Q_INVOKABLE void focusAtPoint(qreal x, qreal y);
    Q_INVOKABLE void setExposureCompensation(qreal value);
    Q_INVOKABLE void setWhiteBalance(const QString &mode);
    Q_INVOKABLE void captureBurst(int count);
    Q_INVOKABLE void enableHDR(bool enabled);

signals:
    void photoCaptured(const QString &filePath);
    void videoRecordingStarted(const QString &filePath);
    void videoRecordingStopped(const QString &filePath, int duration);
    void recordingChanged(bool recording);
    void flashEnabledChanged(bool enabled);
    void zoomLevelChanged(int level);
    void modeChanged(const QString &mode);
    void errorOccurred(const QString &error);
    void captureProgress(int progress);

private:
    CameraModel *m_cameraModel = nullptr;
    bool m_isRecording = false;
    bool m_flashEnabled = false;
    int m_zoomLevel = 1;
    QString m_currentMode = "photo";
    QStringList m_availableCameras;
    int m_activeCamera = 0;

    void initializeCamera();
    void updateAvailableCameras();
};