import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System Toast Component
// Types: default, success, error, warning, info
// Positions: top, bottom, center
// Auto-dismiss with progress bar

Item {
    id: root

    // Properties
    property string type: "default"           // default, success, error, warning, info
    property string title: ""
    property string message: ""
    property string actionText: ""
    property string iconSource: ""
    property int duration: 5000               // Auto-dismiss duration (0 = no auto-dismiss)
    property string position: "bottom"        // top, bottom, center
    property real maxWidth: 400
    property real minWidth: 300
    property real borderRadius: tokens.shapes.cardRadius
    property real elevation: 3

    // Internal state
    property bool visible: false
    property real progress: 1.0               // 1.0 = full, 0.0 = expired
    property bool dismissing: false

    // Accessibility
    accessible.name: root.title || root.message || "Notification"
    accessible.role: Accessible.Alert
    accessible.live: Accessible.LivePolite

    // Colors
    property color backgroundColor: getBackgroundColor()
    property color textColor: getTextColor()
    property color iconColor: getIconColor()
    property color progressColor: getProgressColor()
    property color actionColor: getActionColor()

    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
    }

    function getTextColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        return isDark ? c.onSurfaceDark : c.onSurface;
    }

    function getIconColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        switch (type) {
            case "success": return isDark ? c.successContainerDark : c.success;
            case "error": return isDark ? c.errorContainerDark : c.error;
            case "warning": return isDark ? c.warningContainerDark : c.warning;
            case "info": return isDark ? c.primaryContainerDark : c.primary;
            default: return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
        }
    }

    function getProgressColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        switch (type) {
            case "success": return isDark ? c.successDark : c.success;
            case "error": return isDark ? c.errorDark : c.error;
            case "warning": return isDark ? c.warningDark : c.warning;
            case "info": return isDark ? c.primaryDark : c.primary;
            default: return isDark ? c.outlineDark : c.outline;
        }
    }

    function getActionColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;

        return isDark ? c.primaryDark : c.primary;
    }

    // Default icons per type
    property string defaultIcon: getDefaultIcon()
    function getDefaultIcon() {
        switch (type) {
            case "success": return "qrc:/icons/check_circle.svg";
            case "error": return "qrc:/icons/error.svg";
            case "warning": return "qrc:/icons/warning.svg";
            case "info": return "qrc:/icons/info.svg";
            default: return "";
        }
    }

    // Visual
    width: Math.min(root.maxWidth, Math.max(root.minWidth, contentColumn.implicitWidth + tokens.spacing.componentPadding * 2))
    height: contentColumn.implicitHeight + tokens.spacing.componentPadding * 2
    opacity: root.visible ? 1 : 0
    visible: root.visible

    // Background with shadow
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.borderRadius
        color: root.backgroundColor
        border.width: 0

        // Shadow
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: tokens.shadows.getElevation(root.elevation).keyY
            horizontalOffset: 0
            radius: tokens.shadows.getElevation(root.elevation).keyBlur
            samples: 16
            color: tokens.colors.shadow
            transparentBorder: true
            source: bg
        }

        // Progress bar
        Rectangle {
            id: progressBar
            width: root.progress * parent.width
            height: 3
            radius: 0
            color: root.progressColor
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            Behavior on width {
                NumberAnimation {
                    duration: root.duration > 0 ? root.duration : 0
                    easing.type: tokens.motion.easingLinear
                }
            }
        }
    }

    // Content
    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: tokens.spacing.componentPadding
        spacing: tokens.spacing.componentGapSm

        Row {
            id: headerRow
            spacing: tokens.spacing.componentGapSm
            visible: root.title || root.iconSource || root.defaultIcon

            // Icon
            Image {
                id: toastIcon
                source: root.iconSource || root.defaultIcon
                visible: root.iconSource !== "" || root.defaultIcon !== ""
                width: tokens.spacing.iconSizeMd
                height: tokens.spacing.iconSizeMd
                fillMode: Image.PreserveAspectFit
                color: root.iconColor
            }

            // Title
            Text {
                id: titleText
                text: root.title
                font.family: tokens.typography.titleMedium.fontFamily
                font.pixelSize: tokens.typography.titleMedium.fontSize
                font.weight: tokens.typography.titleMedium.fontWeight
                color: root.textColor
                visible: root.title !== ""
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Message
        Text {
            id: messageText
            text: root.message
            font.family: tokens.typography.bodyMedium.fontFamily
            font.pixelSize: tokens.typography.bodyMedium.fontSize
            font.weight: tokens.typography.bodyMedium.fontWeight
            color: root.textColor
            visible: root.message !== ""
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Action button
        Row {
            id: actionRow
            spacing: tokens.spacing.componentGapSm
            visible: root.actionText !== ""
            Layout.alignment: Qt.AlignRight

            Button {
                id: actionButton
                text: root.actionText
                variant: "text"
                font.family: tokens.typography.labelLarge.fontFamily
                font.pixelSize: tokens.typography.labelLarge.fontSize
                font.weight: tokens.typography.labelLarge.fontWeight
                color: root.actionColor
                onClicked: {
                    root.dismissed();
                    root.actionClicked();
                }
            }
        }
    }

    // Close button
    Button {
        id: closeButton
        iconSource: "qrc:/icons/close.svg"
        variant: "text"
        iconSize: tokens.spacing.iconSizeSm
        width: tokens.spacing.iconSizeMd
        height: tokens.spacing.iconSizeMd
        paddingHorizontal: 0
        paddingVertical: 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: tokens.spacing.space1
        visible: root.actionText === "" // Only show if no action button
        onClicked: root.dismissed()
    }

    // Animations
    Behavior on opacity {
        NumberAnimation {
            duration: tokens.motion.durationStandard
            easing.type: root.visible ? tokens.motion.easingDecelerate : tokens.motion.easingAccelerate
        }
    }

    Behavior on y {
        SpringAnimation {
            spring: tokens.motion.springStandard.damping
            spring: tokens.motion.springStandard.stiffness
        }
    }

    // Auto-dismiss timer
    Timer {
        id: dismissTimer
        interval: root.duration
        running: root.visible && root.duration > 0 && !root.dismissing
        repeat: false
        onTriggered: {
            root.dismissing = true;
            root.progress = 0;
            // Wait for progress animation to complete
            Qt.callLater(function() {
                root.dismissed();
            });
        }
    }

    // Progress animation for auto-dismiss
    Behavior on progress {
        NumberAnimation {
            duration: root.duration > 0 ? root.duration : 0
            easing.type: tokens.motion.easingLinear
            onStopped: {
                if (root.progress <= 0 && root.dismissing) {
                    root.dismissing = false;
                }
            }
        }
    }

    // Methods
    function show() {
        root.visible = true;
        root.progress = 1.0;
        root.dismissing = false;
        dismissTimer.restart();
    }

    function hide() {
        root.dismissing = true;
        root.progress = 0;
        root.visible = false;
    }

    signal actionClicked()
    signal dismissed()
}