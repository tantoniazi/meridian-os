import QtQuick
import QtQuick.Controls
import Conexus.DesignSystem.Tokens

// Conexus Design System Switch Component
// States: default, hover, pressed, focused, disabled

Switch {
    id: root

    // Properties
    property real trackWidth: 44
    property real trackHeight: 24
    property real thumbSize: 20
    property real trackRadius: tokens.shapes.switchRadius
    property real thumbRadius: tokens.shapes.switchThumbRadius
    property real spacing: tokens.spacing.componentGap
    property string label: ""
    property string description: ""

    // Internal state
    property bool hovered: containsMouse
    property bool pressed: root.down

    // Accessibility
    accessible.name: root.label || "Switch"
    accessible.description: root.description
    accessible.role: Accessible.CheckBox
    accessible.checked: root.checked
    accessible.focusable: root.enabled
    Accessible.onPressAction: {
        if (root.enabled) {
            root.checked = !root.checked;
        }
    }

    // Colors
    property color trackColorOn: getTrackColorOn()
    property color trackColorOff: getTrackColorOff()
    property color thumbColorOn: getThumbColorOn()
    property color thumbColorOff: getThumbColorOff()

    function getTrackColorOn() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                          (isDark ? c.surfaceContainerHighestDark : c.surfaceContainerHigh);
        }
        return isDark ? c.primaryContainerDark : c.primaryContainer;
    }

    function getTrackColorOff() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.outlineHCDark : c.outlineHC) :
                          (isDark ? c.outlineVariantDark : c.outlineVariant);
        }
        return isDark ? c.outlineVariantDark : c.outlineVariant;
    }

    function getThumbColorOn() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.primaryDark : c.primary;
    }

    function getThumbColorOff() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    // Visual
    width: root.trackWidth + (root.label ? root.spacing + labelText.implicitWidth : 0)
    height: Math.max(root.trackHeight, labelText.implicitHeight)

    // Track
    background: Rectangle {
        id: track
        width: root.trackWidth
        height: root.trackHeight
        radius: root.trackRadius
        color: root.checked ? root.trackColorOn : root.trackColorOff
        x: 0
        y: (parent.height - height) / 2

        // Focus ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: root.trackRadius + 4
            color: "transparent"
            border.color: tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary
            border.width: 2
            opacity: root.focus && root.enabled ? 1 : 0
            visible: root.focus && root.enabled
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }

        // Disabled overlay
        Rectangle {
            anchors.fill: parent
            color: tokens.isDark() ? "#000000" : "#FFFFFF"
            radius: root.trackRadius
            opacity: root.enabled ? 0 : (tokens.isHighContrast() ? 0 : 0.12)
            visible: !root.enabled
        }
    }

    // Thumb
    contentItem: Rectangle {
        id: thumb
        width: root.thumbSize
        height: root.thumbSize
        radius: root.thumbRadius
        color: root.checked ? root.thumbColorOn : root.thumbColorOff
        x: root.checked ? (root.trackWidth - root.thumbSize) : 0
        y: (root.trackHeight - root.thumbSize) / 2

        // Shadow
        layer.enabled: root.enabled
        layer.effect: DropShadow {
            verticalOffset: tokens.shadows.elevation1.keyY
            horizontalOffset: 0
            radius: tokens.shadows.elevation1.keyBlur
            samples: 16
            color: tokens.colors.shadow
            transparentBorder: true
            source: thumb
        }

        // Ripple
        Rectangle {
            id: ripple
            anchors.fill: parent
            radius: root.thumbRadius
            color: root.thumbColorOn
            opacity: 0
            visible: root.pressed && root.enabled

            NumberAnimation on opacity {
                from: 0.12
                to: 0
                duration: tokens.motion.durationStandard
                running: root.pressed && root.enabled
            }
        }

        Behavior on x {
            SpringAnimation {
                spring: tokens.motion.springStandard.damping
                spring: tokens.motion.springStandard.stiffness
            }
        }
        Behavior on color {
            ColorAnimation { duration: tokens.motion.durationStandard }
        }
    }

    // Label
    Text {
        id: labelText
        text: root.label
        font.family: tokens.typography.bodyMedium.fontFamily
        font.pixelSize: tokens.typography.bodyMedium.fontSize
        font.weight: tokens.typography.bodyMedium.fontWeight
        color: tokens.isDark() ? tokens.colors.onSurfaceDark : tokens.colors.onSurface
        x: root.trackWidth + root.spacing
        y: (parent.height - height) / 2
        visible: root.label !== ""
        elide: Text.ElideRight
    }

    // Touch area for label
    MouseArea {
        id: labelMouseArea
        anchors.fill: labelText
        enabled: root.enabled && root.label !== ""
        onClicked: root.checked = !root.checked
        hoverEnabled: true
    }

    // Cursor
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
}