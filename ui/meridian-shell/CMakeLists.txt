cmake_minimum_required(VERSION 3.20)
project(meridian-shell VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Qt6 components
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2)
find_package(KF6KirigamiAddons REQUIRED)

# Weston
find_package(Weston REQUIRED)
find_package(Wayland REQUIRED)
find_package(EGL REQUIRED)
find_package(GLESv2 REQUIRED)

# System
find_package(Libinput REQUIRED)
find_package(Libudev REQUIRED)
find_package(Systemd REQUIRED)

# Meridian
find_package(MeridianCore REQUIRED)

# Sources
set(SHELL_SOURCES
    src/main.cpp
    src/compositor/MeridianCompositor.cpp
    src/compositor/DRMBackend.cpp
    src/compositor/SceneGraph.cpp
    src/shell/MeridianShell.cpp
    src/shell/PhoneShell.cpp
    src/shell/TabletShell.cpp
    src/shell/DesktopShell.cpp
    src/panels/TopPanel.cpp
    src/panels/BottomDock.cpp
    src/panels/SidePanel.cpp
    src/panels/QuickSettings.cpp
    src/panels/NotificationsPanel.cpp
    src/panels/AppGrid.cpp
    src/gestures/GestureRecognizer.cpp
    src/gestures/EdgeSwipeGesture.cpp
    src/gestures/PinchGesture.cpp
    src/gestures/ThreeFingerGesture.cpp
    src/input/InputManager.cpp
    src/input/KeyboardManager.cpp
    src/input/TouchManager.cpp
)

# Headers
set(SHELL_HEADERS
    src/compositor/MeridianCompositor.h
    src/compositor/DRMBackend.h
    src/compositor/SceneGraph.h
    src/shell/MeridianShell.h
    src/shell/PhoneShell.h
    src/shell/TabletShell.h
    src/shell/DesktopShell.h
    src/panels/TopPanel.h
    src/panels/BottomDock.h
    src/panels/SidePanel.h
    src/panels/QuickSettings.h
    src/panels/NotificationsPanel.h
    src/panels/AppGrid.h
    src/gestures/GestureRecognizer.h
    src/gestures/EdgeSwipeGesture.h
    src/gestures/PinchGesture.h
    src/gestures/ThreeFingerGesture.h
    src/input/InputManager.h
    src/input/KeyboardManager.h
    src/input/TouchManager.h
)

add_executable(meridian-shell ${SHELL_SOURCES} ${SHELL_HEADERS})

target_link_libraries(meridian-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    KF6::KirigamiAddons
    Weston::Weston
    Wayland::Client
    Wayland::Server
    EGL::EGL
    GLESv2::GLESv2
    Libinput::Libinput
    udev
    MeridianCore
)

target_include_directories(meridian-shell PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Install
install(TARGETS meridian-shell
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-shell.desktop
    DESTINATION share/applications
)

install(FILES
    data/meridian-shell.service
    DESTINATION lib/systemd/user
)