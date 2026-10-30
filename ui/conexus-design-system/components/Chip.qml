import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System Chip Component
// Variants: assist, filter, input, suggestion
// States: default, hover, pressed, focused, disabled, selected

Item {
    id: root

    // Properties
    property string variant: "assist"         // assist, filter, input, suggestion
    property string label: ""
    property string leadingIcon: ""
    property string trailingIcon: ""
    property bool selected: false
    property bool removable: false
    property bool clickable: false
    property bool disabled: false
    property real height: tokens.spacing.space8  // 32
    property real radius: tokens.shapes.chipRadius
    property real paddingHorizontal: tokens.spacing.space3  // 12
    property real iconSize: tokens.spacing.iconSizeSm      // 20
    property real fontSize: tokens.typography.labelMedium.fontSize

    // Internal
    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed

    // Accessibility
    accessible.name: root.label || "Chip"
    accessible.role: root.clickable ? Accessible.Button : Accessible.StaticText
    accessible.selected: root.selected
    accessible.pressed: root.pressed
    accessible.focusable: root.enabled && (root.clickable || root.removable)

    // Colors
    property color backgroundColor: getBackgroundColor()
    property color labelColor: getLabelColor()
    property color iconColor: getIconColor()
    property color borderColor: getBorderColor()

    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (root.disabled) {
            return isDark ? c.surfaceContainerHighestDark : c.surfaceContainerHigh;
        }

        if (root.variant === "filter" || root.variant === "input") {
            if (root.selected) {
                return isDark ? c.primaryContainerDark : c.primaryContainer;
            }
            if (root.pressed) {
                return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
            }
            if (root.hovered) {
                return isDark ? c.surfaceContainerLowDark : c.surfaceContainerLow;
            }
            return isDark ? c.surfaceContainerDark : c.surfaceContainer;
        }

        // assist, suggestion
        if (root.pressed) {
            return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
        }
        if (root.hovered) {
            return isDark ? c.surfaceContainerLowDark : c.surfaceContainerLow;
        }
        return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
    }

    function getLabelColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (root.disabled) {
            return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }

        if ((root.variant === "filter" || root.variant === "input") && root.selected) {
            return isDark ? c.onPrimaryContainerDark : c.onPrimaryContainer;
        }

        return isDark ? c.onSurfaceDark : c.onSurface;
    }

    function getIconColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (root.disabled) {
            return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }

        if ((root.variant === "filter" || root.variant === "input") && root.selected) {
            return isDark ? c.primaryDark : c.primary;
        }

        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    function getBorderColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (root.variant === "filter" || root.variant === "input") {
            if (root.selected) {
                return "transparent";
            }
            return isDark ? c.outlineVariantDark : c.outlineVariant;
        }

        return "transparent";
    }

    // Visual
    width: root.paddingHorizontal * 2 +
           (root.leadingIcon ? root.iconSize + tokens.spacing.iconGap : 0) +
           (root.label ? textItem.implicitWidth : 0) +
           (root.trailingIcon || root.removable ? root.iconSize + tokens.spacing.iconGap : 0)
    height: root.height

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor
        border.width: (root.variant === "filter" || root.variant === "input") ? tokens.shapes.borderWidthOutline : 0
        border.color: root.borderColor

        Behavior on color {
            ColorAnimation { duration: tokens.motion.durationStandard }
        }
        Behavior on border.color {
            ColorAnimation { duration: tokens.motion.durationStandard }
        }

        // Focus ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: root.radius + 2
            color: "transparent"
            border.color: tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary
            border.width: 2
            opacity: root.focus && root.enabled ? 1 : 0
            visible: root.focus && root.enabled
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }
    }

    // Content
    Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: root.paddingHorizontal
        anchors.rightMargin: root.paddingHorizontal
        anchors.verticalCenter: parent.verticalCenter
        spacing: tokens.spacing.iconGap

        // Leading icon
        Image {
            id: leadingIconItem
            source: root.leadingIcon
            visible: root.leadingIcon !== ""
            width: root.iconSize
            height: root.iconSize
            fillMode: Image.PreserveAspectFit
            color: root.iconColor
        }

        // Label
        Text {
            id: textItem
            text: root.label
            font.family: tokens.typography.fontFamilyBase
            font.pixelSize: root.fontSize
            font.weight: tokens.typography.weightMedium
            color: root.labelColor
            elide: Text.ElideRight
        }

        // Trailing icon (for input/suggestion chips)
        Image {
            id: trailingIconItem
            source: root.trailingIcon
            visible: root.trailingIcon !== "" && !root.removable
            width: root.iconSize
            height: root.iconSize
            fillMode: Image.PreserveAspectFit
            color: root.iconColor
        }

        // Remove button
        Image {
            id: removeButton
            source: "qrc:/icons/close.svg"
            visible: root.removable && !root.disabled
            width: root.iconSize * 0.75
            height: root.iconSize * 0.75
            fillMode: Image.PreserveAspectFit
            color: root.iconColor
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

    // Ripple
    Rectangle {
        id: ripple
        anchors.fill: parent
        radius: root.radius
        color: root.iconColor
        opacity: 0
        visible: root.pressed && root.enabled && (root.clickable || root.removable)

        NumberAnimation on opacity {
            from: 0.12
            to: 0
            duration: tokens.motion.durationStandard
            easing.type: tokens.motion.easingDecelerate
            running: root.pressed && root.enabled && (root.clickable || root.removable)
        }
    }

    // Mouse area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled && (root.clickable || root.removable)
        hoverEnabled: true
        onClicked: {
            if (root.clickable) {
                root.clicked();
            }
        }
    }

    // Keyboard
    focusPolicy: root.enabled && (root.clickable || root.removable) ? Qt.TabFocus : Qt.NoFocus
    Keys.onReturnPressed: {
        if (root.enabled && root.clickable) {
            root.clicked();
        }
    }
    Keys.onSpacePressed: {
        if (root.enabled && root.clickable) {
            root.clicked();
        }
    }

    // Cursor
    cursorShape: root.enabled && (root.clickable || root.removable) ? Qt.PointingHandCursor : Qt.ArrowCursor

    signal clicked()
    signal removed()
}