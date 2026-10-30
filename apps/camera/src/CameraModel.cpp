#include "CameraModel.h"
#include <QDebug>
#include <QCamera>
#include <QCameraDevice>
#include <QMediaCaptureSession>
#include <QImageCapture>
#include <QMediaRecorder>
#include <QVideoSink>
#include <QStandardPaths>
#include <QDateTime>
#include <QDir>

CameraModel::CameraModel(QObject *parent)
    : QObject(parent)
    , m_camera(nullptr)
    , m_captureSession(nullptr)
    , m_imageCapture(nullptr)
    , m_mediaRecorder(nullptr)
    , m_videoSink(nullptr)
{
}

CameraModel::~CameraModel()
{
    if (m_mediaRecorder) {
        m_mediaRecorder->stop();
    }
    if (m_captureSession) {
        m_captureSession->stop();
    }
}

bool CameraModel::initialize()
{
    qInfo() << "Initializing Camera Model...";
    
    detectCameras();
    
    if (m_availableCameras.isEmpty()) {
        qWarning() << "No cameras found";
        m_cameraAvailable = false;
        emit cameraAvailableChanged(false);
        return false;
    }
    
    initializeDefaultCamera();
    
    m_cameraAvailable = true;
    emit cameraAvailableChanged(true);
    emit availableCamerasChanged(m_availableCameras);
    emit activeCameraChanged(m_activeCamera);
    
    qInfo() << "Camera Model initialized with" << m_availableCameras.size() << "camera(s)";
    return true;
}

void CameraModel::detectCameras()
{
    m_availableCameras.clear();
    const QList<QCameraDevice> cameras = QMediaDevices::videoInputs();
    
    for (const QCameraDevice &device : cameras) {
        m_availableCameras.append(device.description());
        qInfo() << "Found camera:" << device.description() << "ID:" << device.id();
    }
}

void CameraModel::initializeDefaultCamera()
{
    if (m_availableCameras.isEmpty()) return;
    
    m_activeCamera = 0;
    const QCameraDevice cameraDevice = QMediaDevices::videoInputs().at(m_activeCamera);
    m_camera = new QCamera(cameraDevice, this);
    
    // Create capture session
    m_captureSession = new QMediaCaptureSession(this);
    m_captureSession->setCamera(m_camera);
    
    // Set up image capture
    m_imageCapture = new QImageCapture(m_camera, this);
    m_captureSession->setImageCapture(m_imageCapture);
    
    // Connect signals
    connect(m_imageCapture, &QImageCapture::imageCaptured, this, [this](int id, const QImage &preview) {
        emit frameReady(preview);
    });
    connect(m_imageCapture, &QImageCapture::imageSaved, this, [this](int id, const QString &filePath) {
        emit photoCaptured(filePath);
    });
    connect(m_imageCapture, &QImageCapture::errorOccurred, this, [this](int id, QImageCapture::Error error, const QString &errorString) {
        emit errorOccurred(errorString);
    });
    
    // Set up video recording
    m_mediaRecorder = new QMediaRecorder(m_camera, this);
    m_captureSession->setRecorder(m_mediaRecorder);
    
    connect(m_mediaRecorder, &QMediaRecorder::recorderStateChanged, this, [this](QMediaRecorder::RecorderState state) {
        if (state == QMediaRecorder::RecordingState) {
            // Recording started
        } else if (state == QMediaRecorder::StoppedState) {
            // Recording stopped
        }
    });
    connect(m_mediaRecorder, &QMediaRecorder::errorOccurred, this, [this](QMediaRecorder::Error error, const QString &errorString) {
        emit errorOccurred(errorString);
    });
    connect(m_mediaRecorder, &QMediaRecorder::durationChanged, this, [this](qint64 duration) {
        // Update recording duration
    });
    
    // Video sink for preview
    m_videoSink = new QVideoSink(this);
    m_captureSession->setVideoOutput(m_videoSink);
    
    // Start camera
    m_camera->start();
}

bool CameraModel::cameraAvailable() const
{
    return m_cameraAvailable;
}

QStringList CameraModel::availableCameras() const
{
    return m_availableCameras;
}

int CameraModel::activeCamera() const
{
    return m_activeCamera;
}

QSize CameraModel::previewResolution() const
{
    return m_previewResolution;
}

QSize CameraModel::captureResolution() const
{
    return m_captureResolution;
}

int CameraModel::maxZoom() const
{
    return m_maxZoom;
}

bool CameraModel::switchCamera(int cameraId)
{
    if (cameraId < 0 || cameraId >= m_availableCameras.size()) {
        return false;
    }
    
    if (cameraId == m_activeCamera) {
        return true;
    }
    
    // Stop current camera
    if (m_camera) {
        m_camera->stop();
    }
    
    m_activeCamera = cameraId;
    const QCameraDevice cameraDevice = QMediaDevices::videoInputs().at(m_activeCamera);
    
    delete m_camera;
    m_camera = new QCamera(cameraDevice, this);
    
    // Re-setup capture session
    m_captureSession->setCamera(m_camera);
    
    // Reconnect image capture
    delete m_imageCapture;
    m_imageCapture = new QImageCapture(m_camera, this);
    m_captureSession->setImageCapture(m_imageCapture);
    
    // Reconnect signals
    connect(m_imageCapture, &QImageCapture::imageCaptured, this, [this](int id, const QImage &preview) {
        emit frameReady(preview);
    });
    connect(m_imageCapture, &QImageCapture::imageSaved, this, [this](int id, const QString &filePath) {
        emit photoCaptured(filePath);
    });
    connect(m_imageCapture, &QImageCapture::errorOccurred, this, [this](int id, QImageCapture::Error error, const QString &errorString) {
        emit errorOccurred(errorString);
    });
    
    // Reconnect media recorder
    delete m_mediaRecorder;
    m_mediaRecorder = new QMediaRecorder(m_camera, this);
    m_captureSession->setRecorder(m_mediaRecorder);
    
    connect(m_mediaRecorder, &QMediaRecorder::recorderStateChanged, this, [this](QMediaRecorder::RecorderState state) {
        // Handle state changes
    });
    connect(m_mediaRecorder, &QMediaRecorder::errorOccurred, this, [this](QMediaRecorder::Error error, const QString &errorString) {
        emit errorOccurred(errorString);
    });
    connect(m_mediaRecorder, &QMediaRecorder::durationChanged, this, [this](qint64 duration) {
        // Update duration
    });
    
    // Reconnect video sink
    delete m_videoSink;
    m_videoSink = new QVideoSink(this);
    m_captureSession->setVideoOutput(m_videoSink);
    
    m_camera->start();
    
    emit activeCameraChanged(m_activeCamera);
    return true;
}

bool CameraModel::capturePhoto(const QString &filePath)
{
    if (!m_imageCapture || !m_camera || !m_camera->isActive()) {
        return false;
    }
    
    m_imageCapture->setFileFormat(QImageCapture::FileFormat::JPEG);
    m_imageCapture->setQuality(QImageCapture::Quality::VeryHighQuality);
    m_imageCapture->setResolution(m_captureResolution);
    
    m_imageCapture->captureToFile(filePath);
    return true;
}

bool CameraModel::startVideoRecording(const QString &filePath)
{
    if (!m_mediaRecorder || m_mediaRecorder->recorderState() == QMediaRecorder::RecordingState) {
        return false;
    }
    
    m_mediaRecorder->setOutputLocation(QUrl::fromLocalFile(filePath));
    m_mediaRecorder->setVideoResolution(m_captureResolution);
    m_mediaRecorder->setVideoFrameRate(30);
    m_mediaRecorder->setEncodingMode(QMediaRecorder::ConstantQualityEncoding);
    m_mediaRecorder->setQuality(QMediaRecorder::VeryHighQuality);
    
    m_mediaRecorder->record();
    return true;
}

bool CameraModel::stopVideoRecording(QString &filePath, int &duration)
{
    if (!m_mediaRecorder || m_mediaRecorder->recorderState() != QMediaRecorder::RecordingState) {
        return false;
    }
    
    duration = m_mediaRecorder->duration() / 1000;
    filePath = m_mediaRecorder->actualLocation().toLocalFile();
    m_mediaRecorder->stop();
    return true;
}

void CameraModel::setPreviewResolution(const QSize &size)
{
    if (m_previewResolution != size) {
        m_previewResolution = size;
        emit previewResolutionChanged(size);
    }
}

void CameraModel::setCaptureResolution(const QSize &size)
{
    if (m_captureResolution != size) {
        m_captureResolution = size;
        emit captureResolutionChanged(size);
    }
}

void CameraModel::setFocusMode(const QString &mode)
{
    if (!m_camera) return;
    
    QCamera::FocusMode focusMode;
    if (mode == "auto") focusMode = QCamera::FocusMode::AutoFocus;
    else if (mode == "macro") focusMode = QCamera::FocusMode::MacroFocus;
    else if (mode == "continuous") focusMode = QCamera::FocusMode::ContinuousFocus;
    else focusMode = QCamera::FocusMode::AutoFocus;
    
    m_camera->setFocusMode(focusMode);
}

void CameraModel::setExposureMode(const QString &mode)
{
    if (!m_camera) return;
    
    QCamera::ExposureMode exposureMode;
    if (mode == "auto") exposureMode = QCamera::ExposureMode::Auto;
    else if (mode == "manual") exposureMode = QCamera::ExposureMode::Manual;
    else exposureMode = QCamera::ExposureMode::Auto;
    
    m_camera->setExposureMode(exposureMode);
}

void CameraModel::setWhiteBalance(const QString &mode)
{
    if (!m_camera) return;
    
    QCamera::WhiteBalanceMode wbMode;
    if (mode == "auto") wbMode = QCamera::WhiteBalanceMode::Auto;
    else if (mode == "daylight") wbMode = QCamera::WhiteBalanceMode::Daylight;
    else if (mode == "cloudy") wbMode = QCamera::WhiteBalanceMode::Cloudy;
    else if (mode == "shade") wbMode = QCamera::WhiteBalanceMode::Shade;
    else if (mode == "tungsten") wbMode = QCamera::WhiteBalanceMode::Tungsten;
    else if (mode == "fluorescent") wbMode = QCamera::WhiteBalanceMode::Fluorescent;
    else if (mode == "flash") wbMode = QCamera::WhiteBalanceMode::Flash;
    else wbMode = QCamera::WhiteBalanceMode::Auto;
    
    m_camera->setWhiteBalanceMode(wbMode);
}

QImage CameraModel::capturePreviewFrame()
{
    if (!m_videoSink) return QImage();
    return m_videoSink->videoFrame().toImage();
}