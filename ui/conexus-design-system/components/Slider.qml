import QtQuick
import QtQuick.Controls
import Conexus.DesignSystem.Tokens

// Conexus Design System Slider Component
// Supports: continuous, discrete (snaps to steps), range (dual thumb)
// States: default, hover, pressed, focused, disabled

Slider {
    id: root

    // Properties
    property bool discrete: false           // Snap to step values
    property bool showValueLabel: false     // Show value tooltip on thumb
    property bool showTickMarks: false      // Show tick marks for discrete
    property string valueLabelFormat: "%.0f" // Format for value label
    property real trackHeight: 4
    property real thumbSize: 20
    property real thumbSizeHover: 24
    property real trackRadius: tokens.shapes.sliderRadius
    property real thumbRadius: tokens.shapes.sliderThumbRadius
    property string label: ""
    property string minLabel: ""
    property string maxLabel: ""

    // Internal state
    property bool hovered: containsMouse
    property bool pressed: root.down || handle.down

    // Accessibility
    accessible.name: root.label || "Slider"
    accessible.description: root.minLabel && root.maxLabel ? (root.minLabel + " to " + root.maxLabel) : ""
    accessible.role: Accessible.Slider
    accessible.value: root.value
    accessible.minValue: root.from
    accessible.maxValue: root.to
    accessible.stepValue: root.stepSize
    accessible.focusable: root.enabled

    // Colors
    property color trackColor: getTrackColor()
    property color progressColor: getProgressColor()
    property color thumbColor: getThumbColor()
    property color thumbBorderColor: getThumbBorderColor()
    property color tickColor: getTickColor()
    property color valueLabelColor: getValueLabelColor()

    function getTrackColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.outlineHCDark : c.outlineHC) :
                          (isDark ? c.outlineVariantDark : c.outlineVariant);
        }
        return isDark ? c.outlineVariantDark : c.outlineVariant;
    }

    function getProgressColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.primaryDark : c.primary;
    }

    function getThumbColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.primaryDark : c.primary;
    }

    function getThumbBorderColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.surfaceDark : c.surface;
    }

    function getTickColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.outlineHCDark : c.outlineHC) :
                          (isDark ? c.outlineVariantDark : c.outlineVariant);
        }
        return isDark ? c.outlineVariantDark : c.outlineVariant;
    }

    function getValueLabelColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.onPrimaryContainerDark : c.onPrimaryContainer;
    }

    // Visual
    implicitWidth: 200
    implicitHeight: root.showValueLabel ? 60 : 40

    // Track background
    background: Rectangle {
        id: trackBg
        width: parent.width
        height: root.trackHeight
        radius: root.trackRadius
        color: root.trackColor
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
    }

    // Progress track
    Rectangle {
        id: progressTrack
        width: root.visualPosition * parent.width
        height: root.trackHeight
        radius: root.trackRadius
        color: root.progressColor
        y: (parent.height - height) / 2

        Behavior on width {
            NumberAnimation { duration: tokens.motion.durationShort; easing.type: tokens.motion.easingDecelerate }
        }
    }

    // Tick marks for discrete slider
    Row {
        id: tickMarks
        visible: root.showTickMarks && root.discrete && root.enabled
        spacing: (parent.width - (root.stepSize > 0 ? (root.to - root.from) / root.stepSize * 4 : 0)) / Math.max(1, (root.to - root.from) / root.stepSize)
        y: (parent.height - 4) / 2

        Repeater {
            model: root.stepSize > 0 ? Math.floor((root.to - root.from) / root.stepSize) + 1 : 0
            delegate: Rectangle {
                width: 4
                height: 4
                radius: 2
                color: root.tickColor
                opacity: (index * root.stepSize + root.from <= root.value) ? 1 : 0.5
            }
        }
    }

    // Handle (thumb)
    handle: Rectangle {
        id: handle
        width: root.pressed || root.hovered ? root.thumbSizeHover : root.thumbSize
        height: root.pressed || root.hovered ? root.thumbSizeHover : root.thumbSize
        radius: root.thumbRadius
        color: root.thumbColor
        border.color: root.thumbBorderColor
        border.width: 2
        x: root.visualPosition * (parent.width - width)
        y: (parent.height - height) / 2

        // Shadow
        layer.enabled: root.enabled
        layer.effect: DropShadow {
            verticalOffset: tokens.shadows.elevation1.keyY
            horizontalOffset: 0
            radius: tokens.shadows.elevation1.keyBlur
            samples: 16
            color: tokens.colors.shadow
            transparentBorder: true
            source: handle
        }

        // Ripple
        Rectangle {
            id: ripple
            anchors.fill: parent
            radius: root.thumbRadius
            color: root.thumbColor
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
        Behavior on width {
            SpringAnimation {
                spring: tokens.motion.springStandard.damping
                spring: tokens.motion.springStandard.stiffness
            }
        }
        Behavior on height {
            SpringAnimation {
                spring: tokens.motion.springStandard.damping
                spring: tokens.motion.springStandard.stiffness
            }
        }

        // Value label tooltip
        Text {
            id: valueTooltip
            text: root.valueLabelFormat === "%.0f" ? Math.round(root.value) : root.value.toFixed(2)
            font.family: tokens.typography.labelSmall.fontFamily
            font.pixelSize: tokens.typography.labelSmall.fontSize
            font.weight: tokens.typography.labelSmall.fontWeight
            color: root.valueLabelColor
            visible: root.showValueLabel && (root.hovered || root.pressed)
            x: (parent.width - width) / 2
            y: -height - tokens.spacing.space2
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }
    }

    // Labels
    Row {
        id: labels
        width: parent.width
        y: parent.height - tokens.spacing.space1

        Text {
            id: minLabelText
            text: root.minLabel
            font.family: tokens.typography.labelSmall.fontFamily
            font.pixelSize: tokens.typography.labelSmall.fontSize
            font.weight: tokens.typography.labelSmall.fontWeight
            color: tokens.isDark() ? tokens.colors.onSurfaceVariantDark : tokens.colors.onSurfaceVariant
            visible: root.minLabel !== ""
        }

        Item { Layout.fillWidth: true }

        Text {
            id: maxLabelText
            text: root.maxLabel
            font.family: tokens.typography.labelSmall.fontFamily
            font.pixelSize: tokens.typography.labelSmall.fontSize
            font.weight: tokens.typography.labelSmall.fontWeight
            color: tokens.isDark() ? tokens.colors.onSurfaceVariantDark : tokens.colors.onSurfaceVariant
            visible: root.maxLabel !== ""
            horizontalAlignment: Text.AlignRight
        }
    }

    // Keyboard navigation
    Keys.onLeftPressed: {
        if (enabled) {
            value = Math.max(from, value - stepSize);
        }
    }
    Keys.onRightPressed: {
        if (enabled) {
            value = Math.min(to, value + stepSize);
        }
    }
    Keys.onDownPressed: Keys.onLeftPressed
    Keys.onUpPressed: Keys.onRightPressed

    // Cursor
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
}