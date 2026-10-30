import QtQuick
import Conexus.DesignSystem.Tokens

// Conexus Design System Icon Component
// Wrapper for consistent icon sizing, coloring, and accessibility

Image {
    id: root

    // Properties
    property string name: ""                  // Icon name (for lookup)
    property string source: ""                // Direct source URL
    property real size: tokens.spacing.iconSizeMd  // 24
    property color color: getColor()
    property bool mirrored: false             // RTL mirroring
    property bool decorative: true            // If true, hidden from accessibility

    function getColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.onSurfaceDark : c.onSurface;
    }

    // Visual
    width: root.size
    height: root.size
    fillMode: Image.PreserveAspectFit
    color: root.color
    mirror: root.mirrored

    // Accessibility
    accessible.name: root.decorative ? "" : (root.name || "Icon")
    accessible.role: root.decorative ? Accessible.Ignored : Accessible.Image
    accessible.description: ""

    // Source resolution
    // If name is provided, try to resolve from icon registry
    // For now, use source directly
    source: root.source || (root.name ? "qrc:/icons/" + root.name + ".svg" : "")
}