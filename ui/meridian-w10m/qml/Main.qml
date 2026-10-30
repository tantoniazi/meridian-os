import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import Meridian.W10M

Kirigami.ApplicationWindow {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    title: "Meridian W10M"
    
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
    font.family: settingsModel.language === "en_US" ? "Segoe UI" : "Noto Sans"
    font.pixelSize: settingsModel.fontSize
    
    // Reduced motion
    property bool reducedMotion: settingsModel.reducedMotion
    
    // Navigation
    property string currentView: "start"
    property bool showActionCenter: false
    property bool showAllApps: false
    property bool showSettings: false
    property bool showLockScreen: false
    
    // Navigation function
    function navigateTo(view) {
        currentView = view
        if (view === "actioncenter") showActionCenter = true
        else if (view === "allapps") showAllApps = true
        else if (view === "settings") showSettings = true
        else if (view === "lockscreen") showLockScreen = true
        else if (view === "start") currentView = "start"
    }
    
    // Main view stack
    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: root.currentView === "start" ? 0 : (root.currentView === "allapps" ? 1 : 2)
        
        // Start Screen
        W10MStartScreen {
            appModel: w10mShell.appModel
            tileModel: w10mShell.tileModel
            settingsModel: w10mShell.settingsModel
            
            onNavigateTo: w10mShell.navigation.navigateTo(view)
        }
        
        // All Apps View
        AllAppsView {
            appModel: w10mShell.appModel
            tileModel: w10mShell.tileModel
            settingsModel: w10mShell.settingsModel
            
            onNavigateTo: w10mShell.navigation.navigateTo(view)
        }
        
        // Settings View
        SettingsView {
            appModel: w10mShell.appModel
            tileModel: w10mShell.tileModel
            settingsModel: w10mShell.settingsModel
            
            onNavigateTo: w10mShell.navigation.navigateTo(view)
        }
    }
    
    // Action Center Overlay
    ActionCenterOverlay {
        id: actionCenterOverlay
        visible: w10mShell.showActionCenter
        settingsModel: w10mShell.settingsModel
        
        onClosed: w10mShell.showActionCenter = false
    }
    
    // All Apps Overlay
    AllAppsOverlay {
        id: allAppsOverlay
        visible: w10mShell.showAllApps
        appModel: w10mShell.appModel
        settingsModel: w10mShell.settingsModel
        
        onClosed: w10mShell.showAllApps = false
    }
    
    // Settings Overlay
    SettingsOverlay {
        id: settingsOverlay
        visible: w10mShell.showSettings
        settingsModel: w10mShell.settingsModel
        
        onClosed: w10mShell.showSettings = false
    }
    
    // Lock Screen Overlay
    LockScreenOverlay {
        id: lockScreenOverlay
        visible: w10mShell.showLockScreen
        settingsModel: w10mShell.settingsModel
        
        onClosed: w10mShell.showLockScreen = false
    }
}