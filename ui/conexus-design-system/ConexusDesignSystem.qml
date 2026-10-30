pragma Singleton
import QtQuick
import Conexus.DesignSystem.Tokens
import Conexus.DesignSystem.Components
import Conexus.DesignSystem.Themes

// Conexus Design System - Main entry point
// Provides access to all tokens, components, and themes

QtObject {
    id: conexusDesignSystem

    // Version
    readonly property string version: "1.0.0"
    readonly property string name: "Conexus Design System"

    // Modules
    readonly property var tokens: Tokens {}
    readonly property var components: QtObject {
        readonly property var Button: QtObject { property Component delegate: Button {} }
        readonly property var Card: QtObject { property Component delegate: Card {} }
        readonly property var TextField: QtObject { property Component delegate: TextField {} }
        readonly property var Switch: QtObject { property Component delegate: Switch {} }
        readonly property var Slider: QtObject { property Component delegate: Slider {} }
        readonly property var Avatar: QtObject { property Component delegate: Avatar {} }
        readonly property var Badge: QtObject { property Component delegate: Badge {} }
        readonly property var Toast: QtObject { property Component delegate: Toast {} }
        readonly property var Dialog: QtObject { property Component delegate: Dialog {} }
        readonly property var BottomSheet: QtObject { property Component delegate: BottomSheet {} }
        readonly property var NavigationBar: QtObject { property Component delegate: NavigationBar {} }
        readonly property var AppBar: QtObject { property Component delegate: AppBar {} }
        readonly property var ListItem: QtObject { property Component delegate: ListItem {} }
        readonly property var Chip: QtObject { property Component delegate: Chip {} }
        readonly property var Divider: QtObject { property Component delegate: Divider {} }
        readonly property var ProgressIndicator: QtObject { property Component delegate: ProgressIndicator {} }
        readonly property var Icon: QtObject { property Component delegate: Icon {} }
        readonly property var Typography: QtObject { property Component delegate: Typography {} }
    }
    readonly property var themes: QtObject {
        readonly property var Theme: Theme {}
        readonly property var LightTheme: LightTheme {}
        readonly property var DarkTheme: DarkTheme {}
        readonly property var HighContrastTheme: HighContrastTheme {}
    }

    // Convenience accessors
    readonly property var colors: tokens.colors
    readonly property var typography: tokens.typography
    readonly property var spacing: tokens.spacing
    readonly property var motion: tokens.motion
    readonly property var shapes: tokens.shapes
    readonly property var shadows: tokens.shadows
    readonly property var zIndex: tokens.zIndex

    // Current theme
    property var currentTheme: themes.Theme

    // Helper functions
    function setTheme(themeName) {
        switch (themeName) {
            case "light":
                currentTheme = themes.LightTheme;
                break;
            case "dark":
                currentTheme = themes.DarkTheme;
                break;
            case "highContrast":
                currentTheme = themes.HighContrastTheme;
                break;
            default:
                currentTheme = themes.Theme;
        }
    }

    function getComponent(name) {
        return conexusDesignSystem.components[name];
    }
}