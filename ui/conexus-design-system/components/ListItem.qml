import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System ListItem Component
// Variants: single, two-line, three-line, leading/trailing icons, avatar, checkbox, switch, navigation
// States: default, hover, pressed, focused, disabled, selected

Item {
    id: root

    // Properties
    property string variant: "single"         // single, two-line, three-line
    property string title: ""
    property string subtitle: ""
    property string supportingText: ""
    property string leadingIcon: ""
    property string trailingIcon: ""
    property Component leadingAvatar: null
    property Component leadingControl: null   // Checkbox, Radio, Switch
    property Component trailingControl: null  // Switch, Button, Badge
    property bool clickable: false
    property bool selectable: false
    property bool selected: false
    property bool activated: false            // Highlighted state
    property real height: getHeight()
    property real paddingHorizontal: tokens.spacing.componentPadding
    property real paddingVertical: tokens.spacing.componentPaddingSm
    property real contentSpacing: tokens.spacing.componentGap
    property bool showDivider: false
    property bool dividerInset: true

    function getHeight() {
        switch (variant) {
            case "single": return tokens.spacing.space12;      // 48
            case "two-line": return tokens.spacing.space14;    // 56
            case "three-line": return tokens.spacing.space18;  // 72
            default: return tokens.spacing.space12;
        }
    }

    // Internal
    property bool hovered: mouseArea.containsMouse
    property bool pressed: clickable && mouseArea.pressed

    // Accessibility
    accessible.name: root.title || "List item"
    accessible.description: root.subtitle || root.supportingText || ""
    accessible.role: root.clickable ? Accessible.Button : (root.selectable ? Accessible.ListItem : Accessible.StaticText)
    accessible.selected: root.selected
    accessible.checked: root.selectable && root.selected
    accessible.focusable: root.enabled && (root.clickable || root.selectable)
    Accessible.onPressAction: {
        if (root.enabled && (root.clickable || root.selectable)) {
            root.clicked();
        }
    }

    // Colors
    property color backgroundColor: getBackgroundColor()
    property color titleColor: getTitleColor()
    property color subtitleColor: getSubtitleColor()
    property color supportingColor: getSupportingColor()
    property color iconColor: getIconColor()
    property color dividerColor: getDividerColor()

    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return "transparent";
        }
        if (root.activated) {
            return isDark ? c.primaryContainerDark : c.primaryContainer;
        }
        if (root.selected) {
            return isDark ? c.secondaryContainerDark : c.secondaryContainer;
        }
        if (root.pressed) {
            return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
        }
        if (root.hovered) {
            return isDark ? c.surfaceContainerLowDark : c.surfaceContainerLow;
        }
        return "transparent";
    }

    function getTitleColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }
        if (root.activated) {
            return isDark ? c.onPrimaryContainerDark : c.onPrimaryContainer;
        }
        return isDark ? c.onSurfaceDark : c.onSurface;
    }

    function getSubtitleColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }
        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    function getSupportingColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }
        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    function getIconColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        if (!enabled) {
            return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }
        if (root.activated) {
            return isDark ? c.primaryDark : c.primary;
        }
        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    function getDividerColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.outlineVariantDark : c.outlineVariant;
    }

    // Visual
    width: parent ? parent.width : 400
    height: root.height

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.backgroundColor

        Behavior on color {
            ColorAnimation { duration: tokens.motion.durationShort }
        }
    }

    // Content
    Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: root.paddingHorizontal
        anchors.rightMargin: root.paddingHorizontal
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.contentSpacing

        // Leading control (checkbox, radio, switch)
        Loader {
            id: leadingControlLoader
            sourceComponent: root.leadingControl
            active: root.leadingControl !== null
            width: tokens.spacing.iconSizeMd
            height: tokens.spacing.iconSizeMd
        }

        // Leading avatar
        Loader {
            id: leadingAvatarLoader
            sourceComponent: root.leadingAvatar
            active: root.leadingAvatar !== null && root.leadingControl === null
            width: tokens.spacing.iconSizeLg
            height: tokens.spacing.iconSizeLg
        }

        // Leading icon
        Image {
            id: leadingIconItem
            source: root.leadingIcon
            visible: root.leadingIcon !== "" && root.leadingControl === null && root.leadingAvatar === null
            width: tokens.spacing.iconSizeMd
            height: tokens.spacing.iconSizeMd
            fillMode: Image.PreserveAspectFit
            color: root.iconColor
        }

        // Text content
        Column {
            id: textColumn
            Layout.fillWidth: true
            spacing: tokens.spacing.space1

            Text {
                id: titleText
                text: root.title
                font.family: tokens.typography.bodyLarge.fontFamily
                font.pixelSize: tokens.typography.bodyLarge.fontSize
                font.weight: tokens.typography.bodyLarge.fontWeight
                color: root.titleColor
                elide: Text.ElideRight
                width: parent.width
                visible: root.title !== ""
            }

            Text {
                id: subtitleText
                text: root.subtitle
                font.family: tokens.typography.bodyMedium.fontFamily
                font.pixelSize: tokens.typography.bodyMedium.fontSize
                font.weight: tokens.typography.bodyMedium.fontWeight
                color: root.subtitleColor
                elide: Text.ElideRight
                width: parent.width
                visible: root.variant !== "single" && root.subtitle !== ""
            }

            Text {
                id: supportingTextItem
                text: root.supportingText
                font.family: tokens.typography.bodySmall.fontFamily
                font.pixelSize: tokens.typography.bodySmall.fontSize
                font.weight: tokens.typography.bodySmall.fontWeight
                color: root.supportingColor
                elide: Text.ElideRight
                width: parent.width
                visible: root.variant === "three-line" && root.supportingText !== ""
            }
        }

        // Trailing control
        Loader {
            id: trailingControlLoader
            sourceComponent: root.trailingControl
            active: root.trailingControl !== null
        }

        // Trailing icon
        Image {
            id: trailingIconItem
            source: root.trailingIcon || (root.clickable && !root.trailingControl ? "qrc:/icons/chevron_right.svg" : "")
            visible: (root.trailingIcon !== "" || (root.clickable && !root.trailingControl)) && root.trailingControl === null
            width: tokens.spacing.iconSizeMd
            height: tokens.spacing.iconSizeMd
            fillMode: Image.PreserveAspectFit
            color: root.iconColor
        }
    }

    // Divider
    Rectangle {
        id: divider
        width: root.dividerInset ? (parent.width - root.paddingHorizontal * 2) : parent.width
        height: tokens.shapes.borderWidthThin
        color: root.dividerColor
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.showDivider
    }

    // Ripple
    Rectangle {
        id: ripple
        anchors.fill: parent
        color: root.iconColor
        opacity: 0
        visible: root.pressed && root.enabled && (root.clickable || root.selectable)

        NumberAnimation on opacity {
            from: 0.12
            to: 0
            duration: tokens.motion.durationStandard
            easing.type: tokens.motion.easingDecelerate
            running: root.pressed && root.enabled && (root.clickable || root.selectable)
        }
    }

    // Focus ring
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary
        border.width: 2
        opacity: root.focus && root.enabled && (root.clickable || root.selectable) ? 1 : 0
        visible: root.focus && root.enabled && (root.clickable || root.selectable)
        Behavior on opacity {
            NumberAnimation { duration: tokens.motion.durationShort }
        }
    }

    // Mouse area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled && (root.clickable || root.selectable)
        hoverEnabled: true
        onClicked: {
            if (root.clickable) {
                root.clicked();
            } else if (root.selectable) {
                root.selected = !root.selected;
                root.selectionChanged(root.selected);
            }
        }
    }

    // Keyboard
    focusPolicy: (root.enabled && (root.clickable || root.selectable)) ? Qt.TabFocus : Qt.NoFocus
    Keys.onReturnPressed: {
        if (root.enabled && (root.clickable || root.selectable)) {
            if (root.clickable) {
                root.clicked();
            } else {
                root.selected = !root.selected;
                root.selectionChanged(root.selected);
            }
        }
    }
    Keys.onSpacePressed: {
        if (root.enabled && (root.clickable || root.selectable)) {
            if (root.clickable) {
                root.clicked();
            } else {
                root.selected = !root.selected;
                root.selectionChanged(root.selected);
            }
        }
    }

    // Cursor
    cursorShape: root.enabled && (root.clickable || root.selectable) ? Qt.PointingHandCursor : Qt.ArrowCursor

    signal clicked()
    signal selectionChanged(bool selected)
}