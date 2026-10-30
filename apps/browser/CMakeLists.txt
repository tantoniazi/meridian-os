cmake_minimum_required(VERSION 3.20)
project(meridian-browser VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2 WebEngine WebEngineWidgets)
find_package(KF6KirigamiAddons REQUIRED)

set(BROWSER_SOURCES
    src/main.cpp
    src/BrowserApplication.cpp
    src/BrowserController.cpp
    src/BrowserModel.cpp
    src/views/BrowserView.cpp
    src/views/TabBarView.cpp
    src/views/AddressBarView.cpp
    src/views/BookmarksView.cpp
    src/views/HistoryView.cpp
    src/views/SettingsView.cpp
)

add_executable(meridian-browser ${BROWSER_SOURCES})

target_link_libraries(meridian-browser PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::WebEngine
    Qt6::WebEngineWidgets
    KF6::KirigamiAddons
)

target_include_directories(meridian-browser PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-browser PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-browser
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-browser.desktop
    DESTINATION share/applications
)