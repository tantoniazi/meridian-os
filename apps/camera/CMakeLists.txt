cmake_minimum_required(VERSION 3.20)
project(meridian-camera VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2 Multimedia)
find_package(KF6KirigamiAddons REQUIRED)
find_package(LibCamera REQUIRED)

set(CAMERA_SOURCES
    src/main.cpp
    src/CameraApplication.cpp
    src/CameraController.cpp
    src/CameraModel.cpp
    src/views/CameraView.cpp
    src/views/GalleryView.cpp
    src/views/SettingsView.cpp
)

add_executable(meridian-camera ${CAMERA_SOURCES})

target_link_libraries(meridian-camera PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::Multimedia
    KF6::KirigamiAddons
    LibCamera::LibCamera
)

target_include_directories(meridian-camera PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-camera PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-camera
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-camera.desktop
    DESTINATION share/applications
)