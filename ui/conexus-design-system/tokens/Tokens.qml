pragma Singleton
import QtQuick
import "."

QtObject {
    id: tokens

    // Import all token modules
    readonly property var colors: Colors {}
    readonly property var typography: Typography {}
    readonly property var spacing: Spacing {}
    readonly property var motion: Motion {}
    readonly property var shapes: Shapes {}
    readonly property var shadows: Shadows {}
    readonly property var zIndex: ZIndex {}

    // Theme variants
    readonly property string themeLight: "light"
    readonly property string themeDark: "dark"
    readonly property string themeHighContrast: "highContrast"

    // Current theme (to be set by Theme.qml)
    property string currentTheme: tokens.themeLight

    // Get all tokens as a single object (for easy export)
    function getAll() {
        return {
            colors: tokens.colors,
            typography: tokens.typography,
            spacing: tokens.spacing,
            motion: tokens.motion,
            shapes: tokens.shapes,
            shadows: tokens.shadows,
            zIndex: tokens.zIndex
        };
    }

    // Check if dark theme
    function isDark() {
        return tokens.currentTheme === tokens.themeDark ||
               tokens.currentTheme === tokens.themeHighContrast;
    }

    // Check if high contrast
    function isHighContrast() {
        return tokens.currentTheme === tokens.themeHighContrast;
    }
}