#include "CameraApplication.h"
#include "CameraController.h"
#include "CameraModel.h"
#include <QDebug>

CameraApplication::CameraApplication(QObject *parent)
    : QObject(parent)
{
}

CameraApplication::~CameraApplication() = default;

bool CameraApplication::initialize()
{
    qInfo() << "Initializing Meridian Camera...";
    
    m_cameraModel = std::make_unique<CameraModel>(this);
    m_cameraController = std::make_unique<CameraController>(m_cameraModel.get(), this);
    
    if (!m_cameraController->initialize()) {
        qWarning() << "Failed to initialize camera controller";
        return false;
    }
    
    if (!m_cameraModel->initialize()) {
        qWarning() << "Failed to initialize camera model";
        return false;
    }
    
    qInfo() << "Meridian Camera initialized successfully";
    return true;
}