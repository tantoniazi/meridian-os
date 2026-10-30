cmake_minimum_required(VERSION 3.20)
project(meridian-terminal VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2)
find_package(KF6KirigamiAddons REQUIRED)

set(TERMINAL_SOURCES
    src/main.cpp
    src/TerminalApplication.cpp
    src/TerminalController.cpp
    src/TerminalModel.cpp
    src/views/TerminalView.cpp
    src/views/TabBarView.cpp
    src/views/SettingsView.cpp
    src/terminal/TerminalWidget.cpp
    src/terminal/SessionManager.cpp
)

add_executable(meridian-terminal ${TERMINAL_SOURCES})

target_link_libraries(meridian-terminal PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    KF6::KirigamiAddons
)

target_include_directories(meridian-terminal PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-terminal PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-terminal
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-terminal.desktop
    DESTINATION share/applications
)