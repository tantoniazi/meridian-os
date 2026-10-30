cmake_minimum_required(VERSION 3.20)
project(meridian-home VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2)
find_package(KF6KirigamiAddons REQUIRED)

set(HOME_SOURCES
    src/main.cpp
    src/HomeApplication.cpp
    src/views/MainView.cpp
    src/views/AppGridView.cpp
    src/views/AppDrawerView.cpp
    src/views/WidgetSidebar.cpp
    src/views/SearchView.cpp
    src/views/SettingsView.cpp
    src/models/AppModel.cpp
    src/models/WidgetModel.cpp
    src/models/SettingsModel.cpp
)

add_executable(meridian-home ${HOME_SOURCES})

target_link_libraries(meridian-home PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    KF6::KirigamiAddons
)

target_include_directories(meridian-home PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-home PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-home
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-home.desktop
    DESTINATION share/applications
)