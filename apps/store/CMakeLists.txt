cmake_minimum_required(VERSION 3.20)
project(meridian-store VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2 Network)
find_package(KF6KirigamiAddons REQUIRED)

set(STORE_SOURCES
    src/main.cpp
    src/StoreApplication.cpp
    src/StoreModel.cpp
    src/StoreController.cpp
    src/views/StoreView.cpp
    src/views/CategoryView.cpp
    src/views/AppDetailView.cpp
    src/views/InstalledView.cpp
    src/views/UpdatesView.cpp
    src/views/SearchView.cpp
    src/views/SettingsView.cpp
)

add_executable(meridian-store ${STORE_SOURCES})

target_link_libraries(meridian-store PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::Network
    KF6::KirigamiAddons
)

target_include_directories(meridian-store PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-store PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-store
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-store.desktop
    DESTINATION share/applications
)