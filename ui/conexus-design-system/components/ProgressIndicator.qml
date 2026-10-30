import QtQuick
import QtQuick.Controls
import Conexus.DesignSystem.Tokens

// Conexus Design System ProgressIndicator Component
// Types: linear (determinate, indeterminate), circular (determinate, indeterminate)
// Sizes: small, medium, large

Item {
    id: root

    // Properties
    property string type: "linear"            // linear, circular
    property string mode: "determinate"       // determinate, indeterminate
    property real value: 0                    // 0.0 to 1.0
    property real size: "medium"              // small, medium, large
    property real trackHeight: getTrackHeight()
    property real strokeWidth: getStrokeWidth()
    property real radius: tokens.shapes.progressRadius
    property color trackColor: getTrackColor()
    property color progressColor: getProgressColor()
    property bool showValueLabel: false
    property string valueLabelFormat: "%p%"   // %p% = percentage, %v% = value, %m% = max

    function getTrackHeight() {
        switch (size) {
            case "small": return 4;
            case "medium": return 8;
            case "large": return 12;
            default: return 8;
        }
    }

    function getStrokeWidth() {
        switch (size) {
            case "small": return 3;
            case "medium": return 4;
            case "large": return 6;
            default: return 4;
        }
    }

    function getTrackColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.surfaceContainerHighestDark : c.surfaceContainerHighest;
    }

    function getProgressColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.primaryDark : c.primary;
    }

    // Accessibility
    accessible.name: "Progress indicator"
    accessible.role: Accessible.ProgressBar
    accessible.value: root.value
    accessible.minValue: 0
    accessible.maxValue: 1

    // Visual
    width: root.type === "linear" ? (parent ? parent.width : 200) : getDiameter()
    height: root.type === "circular" ? getDiameter() : root.trackHeight

    function getDiameter() {
        switch (size) {
            case "small": return 24;
            case "medium": return 40;
            case "large": return 56;
            default: return 40;
        }
    }

    // Linear progress
    Item {
        id: linearProgress
        visible: root.type === "linear"
        anchors.fill: parent

        // Track
        Rectangle {
            id: linearTrack
            width: parent.width
            height: root.trackHeight
            radius: root.radius
            color: root.trackColor
            anchors.verticalCenter: parent.verticalCenter
        }

        // Progress
        Rectangle {
            id: linearProgressBar
            width: root.mode === "determinate" ? root.value * parent.width : parent.width / 3
            height: root.trackHeight
            radius: root.radius
            color: root.progressColor
            anchors.verticalCenter: parent.verticalCenter

            // Indeterminate animation
            x: root.mode === "indeterminate" ? indeterminateX : 0

            Behavior on width {
                NumberAnimation {
                    duration: tokens.motion.durationEmphasized
                    easing.type: tokens.motion.easingDecelerate
                }
            }
            Behavior on x {
                NumberAnimation {
                    duration: tokens.motion.durationEmphasized
                    easing.type: tokens.motion.easingStandard
                }
            }
        }

        // Value label
        Text {
            id: linearValueLabel
            text: root.valueLabelFormat.replace("%p%", Math.round(root.value * 100))
                                        .replace("%v%", root.value.toFixed(2))
                                        .replace("%m%", "1.00")
            font.family: tokens.typography.labelSmall.fontFamily
            font.pixelSize: tokens.typography.labelSmall.fontSize
            font.weight: tokens.typography.labelSmall.fontWeight
            color: tokens.isDark() ? tokens.colors.onSurfaceDark : tokens.colors.onSurface
            visible: root.showValueLabel && root.mode === "determinate"
            anchors.right: parent.right
            anchors.bottom: linearTrack.top
            anchors.bottomMargin: tokens.spacing.space1
        }
    }

    // Circular progress
    Item {
        id: circularProgress
        visible: root.type === "circular"
        width: getDiameter()
        height: getDiameter()
        anchors.centerIn: parent

        // Track circle
        Canvas {
            id: circularTrack
            width: parent.width
            height: parent.height
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.lineWidth = root.strokeWidth;
                ctx.strokeStyle = root.trackColor;
                ctx.lineCap = "round";
                var radius = (width - root.strokeWidth) / 2;
                ctx.beginPath();
                ctx.arc(width / 2, height / 2, radius, 0, 2 * Math.PI);
                ctx.stroke();
            }
        }

        // Progress circle
        Canvas {
            id: circularProgressBar
            width: parent.width
            height: parent.height
            antialiasing: true

            property real progressAngle: 0

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.lineWidth = root.strokeWidth;
                ctx.strokeStyle = root.progressColor;
                ctx.lineCap = "round";
                var radius = (width - root.strokeWidth) / 2;
                var startAngle = -Math.PI / 2; // Start at top
                var endAngle = startAngle + (root.mode === "determinate" ? root.value * 2 * Math.PI : circularProgressBar.progressAngle);

                ctx.beginPath();
                ctx.arc(width / 2, height / 2, radius, startAngle, endAngle);
                ctx.stroke();
            }

            // Indeterminate animation
            NumberAnimation on progressAngle {
                from: 0
                to: 2 * Math.PI * 2
                duration: 1500
                loops: Animation.Infinite
                running: root.mode === "indeterminate"
                easing.type: Easing.InOutQuad
            }

            // Rotate animation for indeterminate
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1333
                loops: Animation.Infinite
                running: root.mode === "indeterminate"
            }
        }

        // Value label
        Text {
            id: circularValueLabel
            text: root.valueLabelFormat.replace("%p%", Math.round(root.value * 100))
                                        .replace("%v%", root.value.toFixed(2))
                                        .replace("%m%", "1.00")
            font.family: tokens.typography.titleMedium.fontFamily
            font.pixelSize: tokens.typography.titleMedium.fontSize
            font.weight: tokens.typography.titleMedium.fontWeight
            color: tokens.isDark() ? tokens.colors.onSurfaceDark : tokens.colors.onSurface
            visible: root.showValueLabel && root.mode === "determinate"
            anchors.centerIn: parent
        }
    }

    // Indeterminate animation for linear
    property real indeterminateX: 0

    SequentialAnimation on indeterminateX {
        running: root.type === "linear" && root.mode === "indeterminate"
        loops: Animation.Infinite
        NumberAnimation {
            from: -parent.width / 3
            to: parent.width
            duration: 1000
            easing.type: Easing.InOutQuad
        }
        PauseAnimation { duration: 200 }
    }
}