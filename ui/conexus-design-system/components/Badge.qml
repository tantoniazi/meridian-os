import QtQuick
import QtQuick.Controls
import Conexus.DesignSystem.Tokens

// Conexus Design System Badge Component
// Variants: standard, large, dot, icon
// Colors: primary, secondary, error, warning, success, outline

Item {
    id: root

    // Properties
    property string variant: "standard"     // standard, large, dot, icon
    property string colorVariant: "primary" // primary, secondary, error, warning, success, outline, surface
    property string text: ""
    property string iconSource: ""
    property real iconSize: tokens.spacing.iconSizeXs
    property real height: getHeight()
    property real radius: tokens.shapes.badgeRadius
    property real paddingHorizontal: getPaddingHorizontal()
    property real paddingVertical: getPaddingVertical()
    property real fontSize: getFontSize()
    property int fontWeight: tokens.typography.weightMedium
    property bool clickable: false
    property bool removable: false
    property string removeIcon: "qrc:/icons/close.svg"

    function getHeight() {
        switch (variant) {
            case "large": return tokens.spacing.iconSizeMd;  // 24
            case "dot": return tokens.spacing.iconSizeXs;    // 16
            case "icon": return tokens.spacing.iconSizeSm;   // 20
            default: return tokens.spacing.iconSizeSm;       // 20
        }
    }

    function getPaddingHorizontal() {
        switch (variant) {
            case "large": return tokens.spacing.space3;  // 12
            case "dot": return 0;
            case "icon": return tokens.spacing.space2;   // 8
            default: return tokens.spacing.space2;       // 8
        }
    }

    function getPaddingVertical() {
        switch (variant) {
            case "large": return tokens.spacing.space1;  // 4
            default: return 0;
        }
    }

    function getFontSize() {
        switch (variant) {
            case "large": return tokens.typography.labelMedium.fontSize;
            default: return tokens.typography.labelSmall.fontSize;
        }
    }

    // Internal
    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed

    // Accessibility
    accessible.name: root.text || "Badge"
    accessible.role: root.clickable ? Accessible.Button : Accessible.StaticText
    accessible.pressed: root.clickable && root.pressed

    // Colors
    property color backgroundColor: getBackgroundColor()
    property color textColor: getTextColor()
    property color borderColor: getBorderColor()

    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return isDark ? c.surfaceContainerHighestDark : c.surfaceContainerHigh;
        }

        switch (colorVariant) {
            case "primary":
                return isDark ? c.primaryContainerDark : c.primaryContainer;
            case "secondary":
                return isDark ? c.secondaryContainerDark : c.secondaryContainer;
            case "error":
                return isDark ? c.errorContainerDark : c.errorContainer;
            case "warning":
                return isDark ? c.warningContainerDark : c.warningContainer;
            case "success":
                return isDark ? c.successContainerDark : c.successContainer;
            case "outline":
                return "transparent";
            case "surface":
                return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
            default:
                return isDark ? c.primaryContainerDark : c.primaryContainer;
        }
    }

    function getTextColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }

        switch (colorVariant) {
            case "primary":
                return isDark ? c.onPrimaryContainerDark : c.onPrimaryContainer;
            case "secondary":
                return isDark ? c.onSecondaryContainerDark : c.onSecondaryContainer;
            case "error":
                return isDark ? c.onErrorContainerDark : c.onErrorContainer;
            case "warning":
                return isDark ? c.onWarningContainerDark : c.onWarningContainer;
            case "success":
                return isDark ? c.onSuccessContainerDark : c.onSuccessContainer;
            case "outline":
                return isDark ? c.primaryDark : c.primary;
            case "surface":
                return isDark ? c.onSurfaceDark : c.onSurface;
            default:
                return isDark ? c.onPrimaryContainerDark : c.onPrimaryContainer;
        }
    }

    function getBorderColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return isDark ? c.outlineVariantDark : c.outlineVariant;
        }

        switch (colorVariant) {
            case "outline":
                return isDark ? c.outlineDark : c.outline;
            default:
                return "transparent";
        }
    }

    // Visual
    width: root.variant === "dot" ? root.height :
           root.text ? (root.paddingHorizontal * 2 + textItem.implicitWidth + (root.iconSource ? root.iconSize + tokens.spacing.iconGap : 0) + (root.removable ? root.height + tokens.spacing.iconGap : 0)) :
           (root.iconSource ? root.paddingHorizontal * 2 + root.iconSize + (root.removable ? root.height + tokens.spacing.iconGap : 0) : root.height)
    height: root.height

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.variant === "dot" ? root.height / 2 : root.radius
        color: root.backgroundColor
        border.width: root.colorVariant === "outline" ? tokens.shapes.borderWidthOutline : 0
        border.color: root.borderColor

        // Focus ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: root.variant === "dot" ? root.height / 2 + 2 : root.radius + 2
            color: "transparent"
            border.color: tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary
            border.width: 2
            opacity: root.focus && root.enabled && root.clickable ? 1 : 0
            visible: root.focus && root.enabled && root.clickable
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }

        // Hover overlay for clickable
        Rectangle {
            anchors.fill: parent
            radius: root.variant === "dot" ? root.height / 2 : root.radius
            color: tokens.isDark() ? "#FFFFFF" : "#000000"
            opacity: root.hovered && root.clickable && root.enabled ? 0.08 : 0
            visible: root.clickable
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }

        // Pressed overlay
        Rectangle {
            anchors.fill: parent
            radius: root.variant === "dot" ? root.height / 2 : root.radius
            color: tokens.isDark() ? "#FFFFFF" : "#000000"
            opacity: root.pressed && root.clickable && root.enabled ? 0.12 : 0
            visible: root.clickable
        }
    }

    // Content
    Row {
        id: contentRow
        spacing: tokens.spacing.iconGap
        anchors.centerIn: parent
        height: parent.height

        // Icon
        Image {
            id: badgeIcon
            source: root.iconSource
            visible: root.iconSource !== "" && root.variant !== "dot"
            width: root.iconSize
            height: root.iconSize
            fillMode: Image.PreserveAspectFit
            color: root.textColor
        }

        // Text
        Text {
            id: textItem
            text: root.text
            font.family: tokens.typography.fontFamilyBase
            font.pixelSize: root.fontSize
            font.weight: root.fontWeight
            color: root.textColor
            visible: root.text !== "" && root.variant !== "dot"
            elide: Text.ElideRight
        }

        // Remove button
        Image {
            id: removeButton
            source: root.removeIcon
            visible: root.removable && root.variant !== "dot"
            width: root.height * 0.6
            height: root.height * 0.6
            fillMode: Image.PreserveAspectFit
            color: root.textColor
            opacity: 0.7
            MouseArea {
                anchors.fill: parent
                anchors.margins: -tokens.spacing.space1
                onClicked: root.removed()
                hoverEnabled: true
                onEntered: removeButton.opacity = 1
                onExited: removeButton.opacity = 0.7
            }
        }
    }

    // Dot indicator
    Rectangle {
        id: dot
        width: root.height
        height: root.height
        radius: root.height / 2
        color: root.backgroundColor
        border.width: root.colorVariant === "outline" ? tokens.shapes.borderWidthOutline : 0
        border.color: root.borderColor
        visible: root.variant === "dot"
        anchors.centerIn: parent
    }

    // Mouse area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable || root.removable
        hoverEnabled: root.clickable
        onClicked: {
            if (root.clickable) {
                root.clicked();
            }
        }
    }

    // Keyboard
    focusPolicy: (root.clickable || root.removable) ? Qt.TabFocus : Qt.NoFocus
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
    cursorShape: (root.clickable || root.removable) ? Qt.PointingHandCursor : Qt.ArrowCursor

    signal clicked()
    signal removed()
}