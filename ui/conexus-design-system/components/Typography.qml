import QtQuick
import Conexus.DesignSystem.Tokens

// Conexus Design System Typography Component
// Provides styled text elements matching the design system type scale

Text {
    id: root

    // Properties
    property string variant: "bodyMedium"     // displayLarge, displayMedium, displaySmall,
                                              // headlineLarge, headlineMedium, headlineSmall,
                                              // titleLarge, titleMedium, titleSmall,
                                              // bodyLarge, bodyMedium, bodySmall,
                                              // labelLarge, labelMedium, labelSmall
    property string text: ""
    property color color: getColor()
    property bool selectable: false
    property bool wrapMode: false
    property int maxLines: 0
    property real lineHeight: undefined
    property real letterSpacing: undefined

    function getColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.onSurfaceDark : c.onSurface;
    }

    // Get style from tokens
    property var style: getStyle()

    function getStyle() {
        return tokens.typography[root.variant] || tokens.typography.bodyMedium;
    }

    // Apply style
    font.family: root.style.fontFamily
    font.pixelSize: root.style.fontSize
    font.weight: root.style.fontWeight
    lineHeight: root.lineHeight !== undefined ? root.lineHeight : root.style.lineHeight
    letterSpacing: root.letterSpacing !== undefined ? root.letterSpacing : root.style.letterSpacing
    color: root.color
    text: root.text
    elide: root.maxLines > 0 ? Text.ElideRight : Text.ElideNone
    maximumLineCount: root.maxLines > 0 ? root.maxLines : 0
    wrapMode: root.wrapMode ? Text.WordWrap : Text.NoWrap
    selectByMouse: root.selectable

    // Accessibility
    accessible.name: root.text
    accessible.role: Accessible.StaticText
}