cmake_minimum_required(VERSION 3.20)
project(meridian-file-manager VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2)
find_package(KF6KirigamiAddons REQUIRED)

set(FILEMANAGER_SOURCES
    src/main.cpp
    src/FileManagerApplication.cpp
    src/FileManagerModel.cpp
    src/views/FileManagerView.cpp
    src/views/DirectoryView.cpp
    src/views/SidebarView.cpp
    src/views/PropertiesView.cpp
    src/views/SearchView.cpp
    src/operations/FileOperations.cpp
)

add_executable(meridian-file-manager ${FILEMANAGER_SOURCES})

target_link_libraries(meridian-file-manager PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    KF6::KirigamiAddons
)

target_include_directories(meridian-file-manager PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-file-manager PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-file-manager
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-file-manager.desktop
    DESTINATION share/applications
)