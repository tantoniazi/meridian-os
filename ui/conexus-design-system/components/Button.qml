import QtQuick
import QtQuick.Controls
import Conexus.DesignSystem.Tokens

// Conexus Design System Button Component
// Variants: filled, outlined, tonal, text, elevated
// States: default, hover, pressed, focused, disabled, loading

Button {
    id: root

    // Properties
    property string variant: "filled"        // filled, outlined, tonal, text, elevated
    property bool loading: false
    property string loadingText: ""
    property bool iconOnly: false
    property string iconSource: ""
    property bool iconTrailing: false
    property int iconSize: tokens.spacing.iconSizeMd
    property var iconColor: undefined
    property real borderWidth: tokens.shapes.borderWidthOutline
    property real borderRadius: tokens.shapes.buttonRadius
    property real paddingHorizontal: tokens.spacing.componentPadding
    property real paddingVertical: tokens.spacing.componentPaddingSm
    property real minWidth: tokens.spacing.touchTargetMin
    property real minHeight: tokens.spacing.touchTargetMin

    // Accessibility
    accessible.name: text || loadingText || "Button"
    accessible.description: tooltip
    accessible.role: Accessible.Button
    accessible.pressed: down
    accessible.focusable: enabled && !loading
    Accessible.onPressAction: {
        if (enabled && !loading) {
            clicked();
        }
    }

    // Internal state
    property bool hovered: containsMouse
    property bool pressed: down
    property bool focused: focus

    // Colors based on variant and state
    property color backgroundColor: getBackgroundColor()
    property color textColor: getTextColor()
    property color borderColor: getBorderColor()
    property color iconColorResolved: iconColor || textColor
    property color rippleColor: getRippleColor()

    // Animation for state transitions
    property real opacityAnimation: 1
    property real scaleAnimation: 1

    // Variant and state color computation
    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.onSurfaceHCDark : c.outlineHC) :
                          (isDark ? c.surfaceContainerHighestDark : c.surfaceContainerHigh);
        }

        switch (variant) {
            case "filled":
                return pressed ? (isDark ? c.primaryContainerDark : c.primaryContainer) :
                       hovered ? (isDark ? Qt.lighter(c.primaryContainerDark, 1.1) : Qt.lighter(c.primaryContainer, 1.1)) :
                                 (isDark ? c.primaryDark : c.primary);
            case "outlined":
                return pressed ? (isDark ? Qt.darker(c.surfaceContainerHighestDark, 1.1) : Qt.darker(c.surfaceContainerHigh, 1.1)) :
                       hovered ? (isDark ? Qt.lighter(c.surfaceContainerHighestDark, 1.05) : Qt.lighter(c.surfaceContainerHigh, 1.05)) :
                                 "transparent";
            case "tonal":
                return pressed ? (isDark ? Qt.darker(c.secondaryContainerDark, 1.1) : Qt.darker(c.secondaryContainer, 1.1)) :
                       hovered ? (isDark ? Qt.lighter(c.secondaryContainerDark, 1.1) : Qt.lighter(c.secondaryContainer, 1.1)) :
                                 (isDark ? c.secondaryContainerDark : c.secondaryContainer);
            case "text":
                return pressed ? (isDark ? Qt.darker(c.surfaceContainerHighestDark, 1.1) : Qt.darker(c.surfaceContainerHigh, 1.1)) :
                       hovered ? (isDark ? Qt.lighter(c.surfaceContainerHighestDark, 1.05) : Qt.lighter(c.surfaceContainerHigh, 1.05)) :
                                 "transparent";
            case "elevated":
                return pressed ? (isDark ? Qt.darker(c.surfaceContainerDark, 1.1) : Qt.darker(c.surfaceContainer, 1.1)) :
                       hovered ? (isDark ? Qt.lighter(c.surfaceContainerDark, 1.05) : Qt.lighter(c.surfaceContainer, 1.05)) :
                                 (isDark ? c.surfaceContainerDark : c.surfaceContainer);
            default:
                return isDark ? c.primaryDark : c.primary;
        }
    }

    function getTextColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                          (isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant);
        }

        switch (variant) {
            case "filled":
            case "elevated":
                return isDark ? c.onPrimaryDark : c.onPrimary;
            case "outlined":
            case "tonal":
            case "text":
                return isDark ? c.primaryDark : c.primary;
            default:
                return isDark ? c.onPrimaryDark : c.onPrimary;
        }
    }

    function getBorderColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.outlineHCDark : c.outlineHC) :
                          (isDark ? c.outlineVariantDark : c.outlineVariant);
        }

        switch (variant) {
            case "outlined":
                return isDark ? c.outlineDark : c.outline;
            case "tonal":
                return "transparent";
            default:
                return "transparent";
        }
    }

    function getRippleColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        switch (variant) {
            case "filled":
            case "elevated":
                return isDark ? c.onPrimaryDark : c.onPrimary;
            case "outlined":
            case "tonal":
            case "text":
                return isDark ? c.primaryDark : c.primary;
            default:
                return isDark ? c.onPrimaryDark : c.onPrimary;
        }
    }

    // Visual appearance
    background: Rectangle {
        id: bg
        color: root.backgroundColor
        radius: root.borderRadius
        border.color: root.borderColor
        border.width: (root.variant === "outlined") ? root.borderWidth : 0

        // Ripple effect
        Layer {
            id: rippleLayer
            enabled: root.pressed && root.enabled && !root.loading
            opacity: 0
            NumberAnimation on opacity {
                from: 0.12
                to: 0
                duration: tokens.motion.durationStandard
                easing.type: tokens.motion.easingDecelerate
            }
            Rectangle {
                anchors.fill: parent
                color: root.rippleColor
                radius: root.borderRadius
                opacity: rippleLayer.opacity
            }
        }

        // Focus ring
        Rectangle {
            id: focusRing
            anchors.fill: parent
            anchors.margins: -2
            radius: root.borderRadius + 2
            color: "transparent"
            border.color: tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary
            border.width: 2
            opacity: root.focused && root.enabled ? 1 : 0
            visible: root.focused && root.enabled
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }

        // Disabled overlay
        Rectangle {
            anchors.fill: parent
            color: tokens.isDark() ? "#000000" : "#FFFFFF"
            radius: root.borderRadius
            opacity: root.enabled ? 0 : (tokens.isHighContrast() ? 0 : 0.12)
            visible: !root.enabled
        }
    }

    contentItem: Item {
        id: contentRoot
        implicitWidth: Math.max(root.minWidth,
            (root.iconSource ? root.iconSize + tokens.spacing.iconGap : 0) +
            (root.text || root.loadingText ? textItem.implicitWidth : 0) +
            root.paddingHorizontal * 2)
        implicitHeight: Math.max(root.minHeight, root.paddingVertical * 2 + Math.max(root.iconSize, textItem.implicitHeight))

        // Icon
        Image {
            id: iconItem
            source: root.iconSource
            visible: root.iconSource !== "" && !root.loading
            width: root.iconSize
            height: root.iconSize
            fillMode: Image.PreserveAspectFit
            color: root.iconColorResolved
            x: root.iconTrailing ? undefined : root.paddingHorizontal
            right: root.iconTrailing ? root.paddingHorizontal : undefined
            y: (parent.height - height) / 2
        }

        // Loading spinner
        BusyIndicator {
            id: spinner
            visible: root.loading
            running: root.loading
            width: root.iconSize
            height: root.iconSize
            x: root.iconTrailing ? undefined : root.paddingHorizontal
            right: root.iconTrailing ? root.paddingHorizontal : undefined
            y: (parent.height - height) / 2
            color: root.textColor
        }

        // Text
        Text {
            id: textItem
            text: root.loading ? root.loadingText : root.text
            font.family: tokens.typography.labelLarge.fontFamily
            font.pixelSize: tokens.typography.labelLarge.fontSize
            font.weight: tokens.typography.labelLarge.fontWeight
            color: root.textColor
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            x: (root.iconSource || root.loading) && !root.iconTrailing ?
               (root.paddingHorizontal + root.iconSize + tokens.spacing.iconGap) : root.paddingHorizontal
            right: (root.iconSource && root.iconTrailing) ? (root.paddingHorizontal + root.iconSize + tokens.spacing.iconGap) : root.paddingHorizontal
            y: (parent.height - height) / 2
            width: parent.width - x - (right || 0)
        }
    }

    // State animations
    onHoveredChanged: {
        if (hovered && enabled && !loading) {
            scaleAnimation = 1.0
        } else {
            scaleAnimation = 1.0
        }
    }

    onPressedChanged: {
        if (pressed && enabled && !loading) {
            scaleAnimation = 0.98
        } else {
            scaleAnimation = 1.0
        }
    }

    transform: [
        Scale {
            origin.x: width / 2
            origin.y: height / 2
            xScale: root.scaleAnimation
            yScale: root.scaleAnimation
        }
    ]

    Behavior on scaleAnimation {
        SpringAnimation {
            spring: tokens.motion.springStandard.damping
            spring: tokens.motion.springStandard.stiffness
        }
    }

    // Keyboard navigation
    Keys.onReturnPressed: {
        if (enabled && !loading) {
            clicked();
        }
    }
    Keys.onSpacePressed: {
        if (enabled && !loading) {
            clicked();
        }
    }

    // Cursor
    cursorShape: enabled && !loading ? Qt.PointingHandCursor : Qt.ForbiddenCursor
}