#pragma once

#include <QObject>
#include <memory>

class CameraController;
class CameraModel;

class CameraApplication : public QObject
{
    Q_OBJECT
    Q_PROPERTY(CameraController* cameraController READ cameraController CONSTANT)
    Q_PROPERTY(CameraModel* cameraModel READ cameraModel CONSTANT)

public:
    explicit CameraApplication(QObject *parent = nullptr);
    ~CameraApplication() override;

    bool initialize();

    CameraController* cameraController() const { return m_cameraController.get(); }
    CameraModel* cameraModel() const { return m_cameraModel.get(); }

private:
    std::unique_ptr<CameraController> m_cameraController;
    std::unique_ptr<CameraModel> m_cameraModel;
};