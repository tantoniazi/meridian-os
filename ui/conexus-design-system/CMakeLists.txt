cmake_minimum_required(VERSION 3.21)
project(conexus-ui-qt VERSION 1.0.0 LANGUAGES CXX)

# C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Qt 6 components
find_package(Qt6 6.5 REQUIRED COMPONENTS
    Quick
    QuickControls2
    QuickTemplates2
    QuickLayouts
    Svg
)

# Optional: Qt6 ShaderTools for custom effects
find_package(Qt6 6.5 COMPONENTS ShaderTools)

# Build as shared library
add_library(conexus-ui-qt SHARED)

# Include directories
target_include_directories(conexus-ui-qt
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include/conexus-ui-qt>
    PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}
)

# Link Qt libraries
target_link_libraries(conexus-ui-qt PUBLIC
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::QuickLayouts
    Qt6::Svg
)

if (Qt6ShaderTools_FOUND)
    target_link_libraries(conexus-ui-qt PUBLIC Qt6::ShaderTools)
endif()

# Compile definitions
target_compile_definitions(conexus-ui-qt PRIVATE
    CONEXUS_UI_QT_LIBRARY
    QT_NO_KEYWORDS
)

# Source files (C++ backend if any)
# For now, this is a pure QML library
# If you add C++ components later, add them here:
# target_sources(conexus-ui-qt PRIVATE
#     src/ColorUtils.cpp
#     src/AnimationHelper.cpp
# )

# QML module registration
# Generate qmldir and register the module
qt6_add_qml_module(conexus-ui-qt
    URI "Conexus.DesignSystem"
    VERSION 1.0
    QML_FILES
        ConexusDesignSystem.qml
    RESOURCE_PREFIX "/"
    IMPORTS
        QtQuick
        QtQuick.Controls
        QtQuick.Layouts
    PLUGIN_TARGET conexus_ui_qt_plugin
    NO_GENERATE_QMLTYPES
)

# Add subdirectories for tokens, components, themes
# These are added as QML resources
file(GLOB_RECURSE QML_FILES
    "Tokens/*.qml"
    "Components/*.qml"
    "Themes/*.qml"
)

# Add qmldir files
file(GLOB QMLDIR_FILES
    "qmldir"
    "Tokens/qmldir"
    "Components/qmldir"
    "Themes/qmldir"
)

# Create resource file for QML
qt_add_resources(conexus-ui-qt "qml"
    PREFIX "/"
    FILES
        ${QML_FILES}
        ${QMLDIR_FILES}
)

# Install targets
install(TARGETS conexus-ui-qt
    EXPORT conexus-ui-qt-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/conexus-ui-qt
)

# Install QML module
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/qml/Conexus/DesignSystem
    FILES_MATCHING PATTERN "*.qml" PATTERN "qmldir"
)

# Export configuration
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/ConexusUIQtConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/ConexusUIQtConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/ConexusUIQtConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ConexusUIQt
)

install(EXPORT conexus-ui-qt-targets
    FILE ConexusUIQtTargets.cmake
    NAMESPACE ConexusUIQt::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ConexusUIQt
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/ConexusUIQtConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/ConexusUIQtConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ConexusUIQt
)

# Testing
enable_testing()
if (BUILD_TESTING)
    add_subdirectory(tests)
endif()

# Documentation (optional)
# find_package(Qt6DocTools)
# if (Qt6DocTools_FOUND)
#     add_subdirectory(docs)
# endif()