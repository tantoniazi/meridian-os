import QtQuick
import QtQuick.Controls
import Conexus.DesignSystem.Tokens

// Conexus Design System Avatar Component
// Variants: image, initials, icon
// Sizes: xs (24), sm (32), md (40), lg (56), xl (72), xxl (96)
// Shapes: circle, rounded, square

Item {
    id: root

    // Properties
    property string variant: "initials"     // image, initials, icon
    property string size: "md"              // xs, sm, md, lg, xl, xxl
    property string shape: "circle"         // circle, rounded, square
    property string src: ""                 // Image source for image variant
    property string text: ""                // Text for initials variant (name or initials)
    property string iconSource: ""          // Icon source for icon variant
    property color backgroundColor: getBackgroundColor()
    property color textColor: getTextColor()
    property bool clickable: false
    property bool showBadge: false
    property string badgeText: ""
    property color badgeColor: tokens.colors.error
    property real badgeSize: tokens.spacing.iconSizeXs
    property real borderWidth: 0
    property color borderColor: "transparent"

    // Size mapping
    property real pixelSize: getPixelSize()
    property real fontSize: getFontSize()
    property real badgeOffset: getBadgeOffset()

    function getPixelSize() {
        switch (size) {
            case "xs": return 24;
            case "sm": return 32;
            case "md": return 40;
            case "lg": return 56;
            case "xl": return 72;
            case "xxl": return 96;
            default: return 40;
        }
    }

    function getFontSize() {
        switch (size) {
            case "xs": return tokens.typography.labelSmall.fontSize;
            case "sm": return tokens.typography.bodySmall.fontSize;
            case "md": return tokens.typography.bodyMedium.fontSize;
            case "lg": return tokens.typography.headlineSmall.fontSize;
            case "xl": return tokens.typography.headlineMedium.fontSize;
            case "xxl": return tokens.typography.headlineLarge.fontSize;
            default: return tokens.typography.bodyMedium.fontSize;
        }
    }

    function getBadgeOffset() {
        switch (size) {
            case "xs": return -4;
            case "sm": return -4;
            case "md": return -6;
            case "lg": return -8;
            case "xl": return -10;
            case "xxl": return -12;
            default: return -6;
        }
    }

    // Accessibility
    accessible.name: root.text || "Avatar"
    accessible.role: root.clickable ? Accessible.Button : Accessible.Image
    accessible.pressed: root.clickable && mouseArea.pressed

    // Colors
    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        // Generate color from text for initials variant
        if (variant === "initials" && text) {
            var hash = 0;
            for (var i = 0; i < text.length; i++) {
                hash = text.charCodeAt(i) + ((hash << 5) - hash);
            }
            var hue = Math.abs(hash) % 360;
            return Qt.hsla(hue / 360, 0.5, isDark ? 0.4 : 0.5, 1);
        }
        return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
    }

    function getTextColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        // For initials, use onSurface color
        if (variant === "initials") {
            var bg = getBackgroundColor();
            // Calculate luminance to determine text color
            var r = Qt.color(bg).r;
            var g = Qt.color(bg).g;
            var b = Qt.color(bg).b;
            var luminance = 0.299 * r + 0.587 * g + 0.114 * b;
            return luminance > 0.5 ? "#000000" : "#FFFFFF";
        }
        return isDark ? c.onSurfaceDark : c.onSurface;
    }

    // Visual
    width: root.pixelSize
    height: root.pixelSize

    // Radius based on shape
    property real radius: getRadius()
    function getRadius() {
        switch (shape) {
            case "circle": return root.pixelSize / 2;
            case "rounded": return tokens.shapes.avatarRadiusRounded;
            case "square": return 0;
            default: return root.pixelSize / 2;
        }
    }

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor
        border.width: root.borderWidth
        border.color: root.borderColor

        // Image variant
        Image {
            id: avatarImage
            source: root.src
            visible: root.variant === "image" && root.src !== ""
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            clip: true
        }

        // Initials variant
        Text {
            id: initialsText
            text: getInitials(root.text)
            font.family: tokens.typography.fontFamilyBase
            font.pixelSize: root.fontSize
            font.weight: tokens.typography.weightMedium
            color: root.textColor
            visible: root.variant === "initials" && root.text !== ""
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Icon variant
        Image {
            id: avatarIcon
            source: root.iconSource
            visible: root.variant === "icon" && root.iconSource !== ""
            width: root.pixelSize * 0.5
            height: root.pixelSize * 0.5
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            color: root.textColor
        }

        // Placeholder (when no content)
        Image {
            id: placeholder
            source: "qrc:/icons/person.svg"
            visible: (root.variant === "image" && !root.src) ||
                     (root.variant === "initials" && !root.text) ||
                     (root.variant === "icon" && !root.iconSource)
            width: root.pixelSize * 0.5
            height: root.pixelSize * 0.5
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            color: root.textColor
            opacity: 0.5
        }
    }

    // Badge
    Rectangle {
        id: badge
        width: root.badgeSize
        height: root.badgeSize
        radius: root.badgeSize / 2
        color: root.badgeColor
        visible: root.showBadge && root.badgeText !== ""
        x: parent.width + root.badgeOffset
        y: root.badgeOffset

        Text {
            text: root.badgeText
            font.family: tokens.typography.labelSmall.fontFamily
            font.pixelSize: tokens.typography.labelSmall.fontSize
            font.weight: tokens.typography.weightBold
            color: tokens.colors.onError
            anchors.centerIn: parent
        }
    }

    // Click handling
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable
        onClicked: root.clicked()

        Accessible.onPressAction: {
            if (root.clickable) {
                root.clicked();
            }
        }
    }

    // Keyboard
    focusPolicy: root.clickable ? Qt.TabFocus : Qt.NoFocus
    Keys.onReturnPressed: {
        if (root.clickable) {
            root.clicked();
        }
    }
    Keys.onSpacePressed: {
        if (root.clickable) {
            root.clicked();
        }
    }

    // Cursor
    cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor

    // Helper to extract initials
    function getInitials(name) {
        if (!name) return "?";
        var parts = name.trim().split(/\s+/);
        if (parts.length === 1) {
            return parts[0].substring(0, 2).toUpperCase();
        }
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    signal clicked()
}