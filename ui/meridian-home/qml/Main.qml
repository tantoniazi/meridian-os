import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import QtQuick.Window
import Kirigami
import Meridian.Home

Kirigami.ApplicationWindow {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    title: "Meridian Home"
    
    // Theme
    property string currentTheme: settingsModel.theme
    property bool darkMode: settingsModel.darkMode
    
    // Apply theme
    onCurrentThemeChanged: {
        if (currentTheme === "dark") {
            Material.theme = Material.Dark
            Universal.theme = Universal.Dark
        } else if (currentTheme === "light") {
            Material.theme = Material.Light
            Universal.theme = Universal.Light
        } else if (currentTheme === "high-contrast") {
            Material.theme = Material.Dark
            Universal.theme = Universal.Dark
        }
    }
    
    // Accent color
    Material.accent: settingsModel.accentColor
    Universal.accent: settingsModel.accentColor
    
    // Font
    font.family: settingsModel.language === "en_US" ? "Inter Variable" : "Noto Sans"
    font.pixelSize: settingsModel.fontSize
    
    // Reduced motion
    property bool reducedMotion: settingsModel.reducedMotion
    
    // Main view
    MainView {
        id: mainView
        anchors.fill: parent
        
        appModel: homeApp.appModel
        widgetModel: homeApp.widgetModel
        settingsModel: homeApp.settingsModel
        currentPivot: mainView.currentPivot
    }
    
    // Overlay for search
    SearchOverlay {
        id: searchOverlay
        visible: mainView.showSearch
        onClosed: mainView.showSearch = false
    }
    
    // Overlay for app drawer
    AppDrawerOverlay {
        id: appDrawerOverlay
        visible: mainView.showAppDrawer
        onClosed: mainView.showAppDrawer = false
    }
}

Kirigami.ApplicationWindow {
    id: window
    width: 360
    height: 640
    title: "Meridian Home"
    
    // Apply theme
    onCurrentThemeChanged: {
        if (currentTheme === "dark") {
            Material.theme = Material.Dark
            Universal.theme = Universal.Dark
        } else if (currentTheme === "light") {
            Material.theme = Material.Light
            Universal.theme = Universal.Light
        } else if (currentTheme === "high-contrast") {
            Material.theme = Material.Dark
            Universal.theme = Universal.Dark
        }
    }
    
    MainView {
        id: mainView
        anchors.fill: parent
        
        appModel: homeApp.appModel
        widgetModel: homeApp.widgetModel
        settingsModel: homeApp.settingsModel
    }
}