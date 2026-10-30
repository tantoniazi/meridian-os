cmake_minimum_required(VERSION 3.20)
project(meridian-messages VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickWidgets QuickControls2 QuickTemplates2 Multimedia)
find_package(KF6KirigamiAddons REQUIRED)
find_package(ModemManager REQUIRED)

set(MESSAGES_SOURCES
    src/main.cpp
    src/MessagesApplication.cpp
    src/models/ConversationModel.cpp
    src/models/MessageModel.cpp
    src/models/ContactModel.cpp
    src/controllers/MessageController.cpp
    src/controllers/ConversationController.cpp
    src/views/ConversationListView.cpp
    src/views/ConversationView.cpp
    src/views/ComposeView.cpp
    src/views/SettingsView.cpp
)

add_executable(meridian-messages ${MESSAGES_SOURCES})

target_link_libraries(meridian-messages PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::Multimedia
    KF6::KirigamiAddons
    ModemManager::ModemManager
)

target_include_directories(meridian-messages PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(meridian-messages PRIVATE
    QT_NO_KEYWORDS
)

install(TARGETS meridian-messages
    RUNTIME DESTINATION bin
)

install(FILES
    data/meridian-messages.desktop
    DESTINATION share/applications
)