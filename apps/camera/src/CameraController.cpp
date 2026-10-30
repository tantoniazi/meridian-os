#include "CameraController.h"
#include "CameraModel.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDateTime>
#include <QDir>

CameraController::CameraController(CameraModel *cameraModel, QObject *parent)
    : QObject(parent)
    , m_cameraModel(cameraModel)
{
}

CameraController::~CameraController() = default;

bool CameraController::initialize()
{
    qInfo() << "Initializing Camera Controller...";
    
    if (!m_cameraModel->initialize()) {
        qCritical() << "Failed to initialize camera model";
        return false;
    }
    
    // Connect camera model signals
    connect(m_cameraModel, &CameraModel::photoCaptured, this, &CameraController::photoCaptured);
    connect(m_cameraModel, &CameraModel::videoRecordingStarted, this, &CameraController::videoRecordingStarted);
    connect(m_cameraModel, &CameraModel::videoRecordingStopped, this, &CameraController::videoRecordingStopped);
    connect(m_cameraModel, &CameraModel::errorOccurred, this, &CameraController::errorOccurred);
    
    // Update available cameras
    m_availableCameras = m_cameraModel->availableCameras();
    m_activeCamera = m_cameraModel->activeCamera();
    
    qInfo() << "Camera Controller initialized with" << m_availableCameras.size() << "camera(s)";
    return true;
}

void CameraController::takePhoto()
{
    if (!m_cameraModel->cameraAvailable()) {
        emit errorOccurred("No camera available");
        return;
    }
    
    QString fileName = QString("IMG_%1.jpg").arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss"));
    QString picturesDir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    QDir dir(picturesDir);
    if (!dir.exists()) dir.mkpath(".");
    QString filePath = dir.filePath(fileName);
    
    // Emit progress
    emit captureProgress(0);
    
    // Capture photo
    bool success = m_cameraModel->capturePhoto(filePath);
    
    if (success) {
        emit captureProgress(100);
        emit photoCaptured(filePath);
        qInfo() << "Photo captured:" << filePath;
    } else {
        emit errorOccurred("Failed to capture photo");
    }
}

void CameraController::startVideoRecording()
{
    if (m_isRecording) {
        warn("Already recording");
        return;
    }
    
    if (!m_cameraModel->cameraAvailable()) {
        emit errorOccurred("No camera available");
        return;
    }
    
    QString fileName = QString("VID_%1.mp4").arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss"));
    QString moviesDir = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    QDir dir(moviesDir);
    if (!dir.exists()) dir.mkpath(".");
    QString filePath = dir.filePath(fileName);
    
    m_isRecording = true;
    emit recordingChanged(true);
    
    bool success = m_cameraModel->startVideoRecording(filePath);
    
    if (success) {
        qInfo() << "Video recording started:" << filePath;
        emit videoRecordingStarted(filePath);
    } else {
        m_isRecording = false;
        emit recordingChanged(false);
        emit errorOccurred("Failed to start video recording");
    }
}

void CameraController::stopVideoRecording()
{
    if (!m_isRecording) {
        warn("Not recording");
        return;
    }
    
    QString filePath;
    int duration = 0;
    bool success = m_cameraModel->stopVideoRecording(filePath, duration);
    
    m_isRecording = false;
    emit recordingChanged(false);
    
    if (success) {
        qInfo() << "Video recording stopped:" << filePath << "Duration:" << duration << "s";
        emit videoRecordingStopped(filePath, duration);
    } else {
        emit errorOccurred("Failed to stop video recording");
    }
}

void CameraController::toggleFlash()
{
    setFlashEnabled(!m_flashEnabled);
}

void CameraController::setFlashEnabled(bool enabled)
{
    if (m_flashEnabled != enabled) {
        m_flashEnabled = enabled;
        m_cameraModel->setFlashMode(enabled ? "torch" : "off");
        emit flashEnabledChanged(enabled);
    }
}

void CameraController::zoomIn()
{
    int newZoom = qMin(m_zoomLevel + 1, m_cameraModel->maxZoom());
    setZoomLevel(newZoom);
}

void CameraController::zoomOut()
{
    int newZoom = qMax(m_zoomLevel - 1, 1);
    setZoomLevel(newZoom);
}

void CameraController::setZoomLevel(int level)
{
    level = qBound(1, level, m_cameraModel->maxZoom());
    if (m_zoomLevel != level) {
        m_zoomLevel = level;
        m_cameraModel->setZoom(level);
        emit zoomLevelChanged(level);
    }
}

void CameraController::switchCamera(int cameraId)
{
    if (cameraId >= 0 && cameraId < m_availableCameras.size() && cameraId != m_activeCamera) {
        if (m_cameraModel->switchCamera(cameraId)) {
            m_activeCamera = cameraId;
            qInfo() << "Switched to camera:" << cameraId;
        }
    }
}

void CameraController::setCaptureMode(CaptureMode mode)
{
    QString modeStr;
    switch (mode) {
        case Photo: m_currentMode = "photo"; break;
        case Video: m_currentMode = "video"; break;
        case Portrait: m_currentMode = "portrait"; break;
        case Night: m_currentMode = "night"; break;
        case Panorama: m_currentMode = "panorama"; break;
        case SlowMotion: m_currentMode = "slow-motion"; break;
        case TimeLapse: m_currentMode = "time-lapse"; break;
    }
    emit modeChanged(m_currentMode);
}

void CameraController::focusAtPoint(qreal x, qreal y)
{
    m_cameraModel->setFocusPoint(QPointF(x, y));
}

void CameraController::setExposureCompensation(qreal value)
{
    m_cameraModel->setExposureCompensation(value);
}

void CameraController::setWhiteBalance(const QString &mode)
{
    m_cameraModel->setWhiteBalance(mode);
}

void CameraController::captureBurst(int count)
{
    for (int i = 0; i < count; ++i) {
        QTimer::singleShot(i * 100, this, &CameraController::takePhoto);
    }
}

void CameraController::enableHDR(bool enabled)
{
    m_cameraModel->setHDREnabled(enabled);
}

void CameraController::initializeCamera()
{
    m_cameraModel->initialize();
    updateAvailableCameras();
}

void CameraController::updateAvailableCameras()
{
    m_availableCameras = m_cameraModel->availableCameras();
}