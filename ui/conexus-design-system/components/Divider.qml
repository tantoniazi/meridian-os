import QtQuick
import Conexus.DesignSystem.Tokens

// Conexus Design System Divider Component
// Variants: horizontal, vertical
// Styles: full, inset (start, end, both)

Item {
    id: root

    // Properties
    property string orientation: "horizontal" // horizontal, vertical
    property string inset: "none"             // none, start, end, both
    property real thickness: tokens.shapes.dividerRadius === 0 ? 1 : tokens.shapes.borderWidthThin
    property color color: getColor()

    function getColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.outlineVariantDark : c.outlineVariant;
    }

    // Visual
    width: root.orientation === "horizontal" ? (parent ? parent.width : 400) : root.thickness
    height: root.orientation === "vertical" ? (parent ? parent.height : 400) : root.thickness

    Rectangle {
        id: dividerLine
        anchors.fill: parent

        // Handle inset
        anchors.leftMargin: (root.orientation === "horizontal" && (root.inset === "start" || root.inset === "both")) ? tokens.spacing.componentPadding : 0
        anchors.rightMargin: (root.orientation === "horizontal" && (root.inset === "end" || root.inset === "both")) ? tokens.spacing.componentPadding : 0
        anchors.topMargin: (root.orientation === "vertical" && (root.inset === "start" || root.inset === "both")) ? tokens.spacing.componentPadding : 0
        anchors.bottomMargin: (root.orientation === "vertical" && (root.inset === "end" || root.inset === "both")) ? tokens.spacing.componentPadding : 0

        color: root.color
    }
}