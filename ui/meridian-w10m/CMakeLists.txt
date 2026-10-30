cmake_minimum_required(VERSION 3.20)
project(meridian-w10m VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2)
find_package(KF6KirigamiAddons REQUIRED)

set(W10M_SOURCES
    src/main.cpp
    src/shell/W10MShell.cpp
    src/shell/W10MCompositor.cpp
    src/shell/W10MNavigation.cpp
    src/controls/W10MAppBar.cpp
    src/controls/W10MCommandBar.cpp
    src/controls/W10MPivot.cpp
    src/controls/W10MHub.cpp
    src/controls/W10MListView.cpp
    src/controls/W10MTile.cpp
    src/controls/W10MToast.cpp
    src/controls/W10MFlyout.cpp
    src/controls/W10MSettingsFlyout.cpp
    src/controls/W10MProgressRing.cpp
    src/controls/W10MProgressBar.cpp
    src/controls/W10MToggleSwitch.cpp
    src/controls/W10MSlider.cpp
    src/controls/W10MComboBox.cpp
    src/controls/W10MTextBox.cpp
    src/controls/W10MPasswordBox.cpp
    src/controls/W10MDatePicker.cpp
    src/controls/W10MTimePicker.cpp
    src/controls/W10MToggleMenuFlyout.cpp
    src/controls/W10MMenuFlyout.cpp
    src/controls/W10MContentDialog.cpp
    src/controls/W10MSemanticZoom.cpp
    src/controls/W10MFlipView.cpp
    src/controls/W10MListViewBase.cpp
    src/controls/W10MGridView.cpp
    src/controls/W10MListView.cpp
    src/animations/W10MTransition.cpp
    src/animations/W10MThemeTransition.cpp
    src/animations/W10MEntranceTransition.cpp
    src/animations/W10MRepositionTransition.cpp
    src/animations/W10MContentTransition.cpp
    src/animations/W10MRepositionThemeTransition.cpp
    src/views/W10MStartScreen.cpp
    src/views/W10MAllAppsView.cpp
    src/views/W10MSettingsView.cpp
    src/views/W10MActionCenterView.cpp
    src/views/W10MLockScreenView.cpp
    src/views/W10MCallView.cpp
    src/views/W10MMessageView.cpp
    src/views/W10MSettingsView.cpp
    src/models/W10MAppModel.cpp
    src/models/W10MTileModel.cpp
    src/models/W10MSettingsModel.cpp
)

add_executable(meridian-w10m ${W10M_SOURCES})

target_link_libraries(meridian-w10m PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    KF6::KirigamiAddons
)

target_include_directories(meridian-w10m PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-w10m PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-w10m
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-w10m.desktop
    DESTINATION share/applications
)