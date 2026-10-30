import QtQuick
import QtQuick.Controls
import Conexus.DesignSystem.Tokens

// Conexus Design System Card Component
// Variants: elevated, filled, outlined
// Supports header, content, footer, actions

Item {
    id: root

    // Properties
    property string variant: "elevated"     // elevated, filled, outlined
    property real borderRadius: tokens.shapes.cardRadius
    property real elevation: 1              // 0-5
    property color backgroundColor: getBackgroundColor()
    property color borderColor: getBorderColor()
    property bool clickable: false
    property bool hoverable: true
    property string hoverEffect: "elevation" // elevation, overlay, none

    // Content sections
    property Component header: null
    property Component content: null
    property Component footer: null
    property var actions: []                // Array of action objects {text, icon, onClicked, variant}

    // Padding
    property real paddingHorizontal: tokens.spacing.componentPadding
    property real paddingVertical: tokens.spacing.componentPadding
    property real sectionSpacing: tokens.spacing.componentGap

    // Accessibility
    accessible.name: "Card"
    accessible.role: clickable ? Accessible.Button : Accessible.Group
    accessible.pressed: clickable && mouseArea.pressed

    // Internal state
    property bool hovered: mouseArea.containsMouse
    property bool pressed: clickable && mouseArea.pressed

    // Colors
    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        switch (variant) {
            case "filled":
                return isDark ? c.surfaceContainerHighestDark : c.surfaceContainerHigh;
            case "outlined":
                return isDark ? c.surfaceDark : c.surface;
            case "elevated":
            default:
                return isDark ? c.surfaceDark : c.surface;
        }
    }

    function getBorderColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (isHC) {
            return isDark ? c.outlineHCDark : c.outlineHC;
        }

        switch (variant) {
            case "outlined":
                return isDark ? c.outlineDark : c.outline;
            default:
                return "transparent";
        }
    }

    function getElevation() {
        if (variant !== "elevated") return 0;
        var baseElevation = elevation;
        if (pressed) return Math.max(0, baseElevation - 1);
        if (hovered && hoverEffect === "elevation") return baseElevation + 1;
        return baseElevation;
    }

    function getOverlayOpacity() {
        if (!hovered || hoverEffect !== "overlay") return 0;
        var isDark = tokens.isDark();
        return pressed ? (isDark ? 0.12 : 0.08) : (isDark ? 0.08 : 0.04);
    }

    // Shadow effect based on elevation
    property var currentShadow: tokens.shadows.getElevation(getElevation())

    // Background with shadow
    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.borderRadius
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: (root.variant === "outlined") ? tokens.shapes.borderWidthOutline : 0

        // Elevation shadow (using DropShadow effect)
        layer.enabled: root.variant === "elevated" && root.getElevation() > 0
        layer.effect: DropShadow {
            verticalOffset: root.currentShadow.keyY
            horizontalOffset: 0
            radius: root.currentShadow.keyBlur
            samples: 16
            color: tokens.colors.shadow
            transparentBorder: true
            source: background
        }

        // Hover overlay
        Rectangle {
            anchors.fill: parent
            radius: root.borderRadius
            color: tokens.isDark() ? "#FFFFFF" : "#000000"
            opacity: root.getOverlayOpacity()
            visible: root.hoverEffect === "overlay"
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationStandard }
            }
        }

        // Focus ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: root.borderRadius + 2
            color: "transparent"
            border.color: tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary
            border.width: 2
            opacity: root.focus && root.clickable ? 1 : 0
            visible: root.focus && root.clickable
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }
    }

    // Content layout
    Column {
        id: contentColumn
        anchors.fill: parent
        spacing: root.sectionSpacing

        // Header
        Loader {
            id: headerLoader
            sourceComponent: root.header
            active: root.header !== null
            Layout.fillWidth: true
        }

        // Content
        Loader {
            id: contentLoader
            sourceComponent: root.content
            active: root.content !== null
            Layout.fillWidth: true
        }

        // Footer with actions
        Loader {
            id: footerLoader
            sourceComponent: root.footer
            active: root.footer !== null
            Layout.fillWidth: true
        }

        // Default actions row if actions array provided
        Row {
            id: actionsRow
            visible: root.actions.length > 0 && !root.footer
            spacing: tokens.spacing.componentGapSm
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight

            Repeater {
                model: root.actions
                delegate: Button {
                    text: modelData.text
                    iconSource: modelData.icon
                    variant: modelData.variant || "text"
                    onClicked: modelData.onClicked()
                    enabled: modelData.enabled !== false
                }
            }
        }
    }

    // Mouse area for clickable cards
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.hoverable
        onClicked: {
            if (root.clickable) {
                root.clicked();
            }
        }

        // Accessibility press action
        Accessible.onPressAction: {
            if (root.clickable) {
                root.clicked();
            }
        }
    }

    // Keyboard navigation for clickable cards
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

    // Signal for clickable cards
    signal clicked()
}