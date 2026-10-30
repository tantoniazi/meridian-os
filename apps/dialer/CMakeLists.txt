cmake_minimum_required(VERSION 3.20)
project(meridian-dialer VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2 Multimedia)
find_package(KF6KirigamiAddons REQUIRED)
find_package(ModemManager REQUIRED)
find_package(Ofono REQUIRED)

set(DIALER_SOURCES
    src/main.cpp
    src/DialerApplication.cpp
    src/models/CallModel.cpp
    src/models/ContactModel.cpp
    src/models/USSDModel.cpp
    src/views/DialPadView.cpp
    src/views/CallLogView.cpp
    src/views/ContactsView.cpp
    src/views/CallView.cpp
    src/views/USSDView.cpp
    src/views/VoicemailView.cpp
    src/controllers/CallController.cpp
    src/controllers/ContactController.cpp
    src/controllers/USSDController.cpp
)

add_executable(meridian-dialer ${DIALER_SOURCES})

target_link_libraries(meridian-dialer PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::Multimedia
    KF6::KirigamiAddons
    ModemManager::ModemManager
    Ofono::Ofono
)

target_include_directories(meridian-dialer PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-dialer PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-dialer
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-dialer.desktop
    DESTINATION share/applications
)