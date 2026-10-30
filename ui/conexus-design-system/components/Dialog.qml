import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System Dialog Component
// Types: alert, confirmation, form, fullscreen
// Sizes: small, medium, large, fullscreen

Dialog {
    id: root

    // Properties
    property string dialogType: "alert"       // alert, confirmation, form, fullscreen
    property string size: "medium"            // small, medium, large, fullscreen
    property string title: ""
    property string message: ""
    property Component content: null          // Custom content component
    property var actions: []                  // Array of {text, variant, onClicked, enabled, role}
    property string alignment: "center"       // center, start, end
    property bool dismissible: true           // Click overlay to dismiss
    property bool closeOnEscape: true
    property real borderRadius: tokens.shapes.dialogRadius
    property real maxWidth: getMaxWidth()
    property real minWidth: getMinWidth()

    function getMaxWidth() {
        switch (size) {
            case "small": return 360;
            case "medium": return 480;
            case "large": return 640;
            case "fullscreen": return 10000;
            default: return 480;
        }
    }

    function getMinWidth() {
        switch (size) {
            case "small": return 280;
            case "medium": return 360;
            case "large": return 480;
            case "fullscreen": return 0;
            default: return 360;
        }
    }

    // Internal
    property bool animating: false

    // Accessibility
    accessible.name: root.title || "Dialog"
    accessible.role: Accessible.Dialog
    accessible.modal: true

    // Colors
    property color backgroundColor: getBackgroundColor()
    property color overlayColor: getOverlayColor()

    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.surfaceDark : c.surface;
    }

    function getOverlayColor() {
        var isDark = tokens.isDark();
        return isDark ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(0, 0, 0, 0.32);
    }

    // Modal setup
    modal: true
    focus: true
    standardButtons: Dialog.NoButton
    x: (parent ? parent.width : 0) / 2 - width / 2
    y: (parent ? parent.height : 0) / 2 - height / 2

    // Overlay
    overlay: Rectangle {
        id: overlay
        color: root.overlayColor
        opacity: root.visible ? 1 : 0
        visible: root.visible

        Behavior on opacity {
            NumberAnimation {
                duration: tokens.motion.durationStandard
                easing.type: root.visible ? tokens.motion.easingDecelerate : tokens.motion.easingAccelerate
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.dismissible
            onClicked: root.dismissible && root.close()
        }
    }

    // Background
    background: Rectangle {
        id: dialogBg
        radius: root.borderRadius
        color: root.backgroundColor
        border.width: 0

        // Shadow
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: tokens.shadows.elevation4.keyY
            horizontalOffset: 0
            radius: tokens.shadows.elevation4.keyBlur
            samples: 32
            color: tokens.colors.shadow
            transparentBorder: true
            source: dialogBg
        }
    }

    // Content
    contentItem: Column {
        id: contentColumn
        width: Math.min(root.maxWidth, Math.max(root.minWidth, childrenRect.width))
        spacing: 0

        // Header
        Rectangle {
            id: header
            width: parent.width
            height: root.title ? tokens.spacing.space6 * 2 : 0
            visible: root.title !== "" || root.dialogType === "confirmation"

            Column {
                anchors.fill: parent
                anchors.margins: tokens.spacing.componentPadding
                spacing: tokens.spacing.space1

                Text {
                    id: titleText
                    text: root.title
                    font.family: tokens.typography.titleLarge.fontFamily
                    font.pixelSize: tokens.typography.titleLarge.fontSize
                    font.weight: tokens.typography.titleLarge.fontWeight
                    color: tokens.isDark() ? tokens.colors.onSurfaceDark : tokens.colors.onSurface
                    visible: root.title !== ""
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
        }

        // Divider
        Rectangle {
            id: divider
            width: parent.width
            height: tokens.shapes.borderWidthThin
            color: tokens.isDark() ? tokens.colors.outlineVariantDark : tokens.colors.outlineVariant
            visible: root.title !== "" && (root.message !== "" || root.content)
        }

        // Body
        Column {
            id: body
            width: parent.width
            spacing: tokens.spacing.componentGap
            Layout.fillWidth: true

            // Message text
            Text {
                id: messageText
                text: root.message
                font.family: tokens.typography.bodyMedium.fontFamily
                font.pixelSize: tokens.typography.bodyMedium.fontSize
                font.weight: tokens.typography.bodyMedium.fontWeight
                color: tokens.isDark() ? tokens.colors.onSurfaceVariantDark : tokens.colors.onSurfaceVariant
                visible: root.message !== "" && !root.content
                wrapMode: Text.WordWrap
                width: parent.width - tokens.spacing.componentPadding * 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Custom content
            Loader {
                id: contentLoader
                sourceComponent: root.content
                active: root.content !== null
                width: parent.width - tokens.spacing.componentPadding * 2
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Actions
        Row {
            id: actionsRow
            width: parent.width
            height: tokens.spacing.space6 * 2
            spacing: tokens.spacing.componentGapSm
            visible: root.actions.length > 0
            Layout.alignment: root.alignment === "start" ? Qt.AlignLeft :
                              root.alignment === "end" ? Qt.AlignRight : Qt.AlignHCenter

            Repeater {
                model: root.actions
                delegate: Button {
                    id: actionBtn
                    text: modelData.text
                    variant: modelData.variant || (modelData.role === "primary" ? "filled" : "text")
                    enabled: modelData.enabled !== false
                    onClicked: {
                        modelData.onClicked();
                        if (modelData.dismiss !== false) {
                            root.close();
                        }
                    }
                }
            }
        }
    }

    // Animations
    property real scale: 1
    property real opacity: 0

    onVisibleChanged: {
        if (visible) {
            scale = 0.9;
            opacity = 0;
            animating = true;
            scale = 1;
            opacity = 1;
        } else {
            animating = true;
            scale = 0.9;
            opacity = 0;
        }
    }

    Behavior on scale {
        SpringAnimation {
            spring: tokens.motion.springStandard.damping
            spring: tokens.motion.springStandard.stiffness
            onStopped: animating = false
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: tokens.motion.durationStandard
            easing.type: visible ? tokens.motion.easingDecelerate : tokens.motion.easingAccelerate
            onStopped: animating = false
        }
    }

    // Escape key handling
    Keys.onEscapePressed: {
        if (root.closeOnEscape) {
            root.close();
        }
    }

    // Methods
    function open() {
        root.visible = true;
    }

    function close() {
        root.visible = false;
    }

    // Signal
    signal accepted()
    signal rejected()
    signal closed()
}