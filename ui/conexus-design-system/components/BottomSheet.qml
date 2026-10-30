import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System BottomSheet Component
// Types: standard, modal, persistent
// Heights: auto, half, full, custom

Item {
    id: root

    // Properties
    property string sheetType: "standard"     // standard, modal, persistent
    property real height: getHeight()
    property real maxHeight: parent ? parent.height * 0.9 : 600
    property real minHeight: tokens.spacing.space16  // 64
    property real dragHandleHeight: 24
    property real borderRadius: tokens.shapes.bottomSheetRadius
    property bool dismissible: true
    property bool dragToDismiss: true
    property Component content: null
    property var actions: []                  // Array of {text, variant, onClicked, role}
    property string title: ""
    property string subtitle: ""
    property bool showDragHandle: true

    function getHeight() {
        return parent ? parent.height / 2 : 400;
    }

    // Internal state
    property real currentY: parent ? parent.height : 0
    property real targetY: parent ? parent.height - height : 0
    property bool dragging: false
    property real dragStartY: 0
    property real sheetStartY: 0
    property bool animating: false

    // Accessibility
    accessible.name: root.title || "Bottom sheet"
    accessible.role: Accessible.Dialog
    accessible.modal: root.sheetType === "modal"

    // Colors
    property color backgroundColor: getBackgroundColor()
    property color overlayColor: getOverlayColor()
    property color handleColor: getHandleColor()

    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.surfaceDark : c.surface;
    }

    function getOverlayColor() {
        var isDark = tokens.isDark();
        return root.sheetType === "modal" ? (isDark ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(0, 0, 0, 0.32)) : "transparent";
    }

    function getHandleColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.outlineVariantDark : c.outlineVariant;
    }

    // Visual
    width: parent ? parent.width : 400
    height: root.currentY < (parent ? parent.height : 0) ? root.height : 0
    y: root.currentY
    visible: root.currentY < (parent ? parent.height : 0)
    z: tokens.zIndex.bottomSheet

    // Overlay
    Rectangle {
        id: overlay
        width: parent ? parent.width : 0
        height: parent ? parent.height : 0
        color: root.overlayColor
        opacity: root.visible ? 1 : 0
        visible: root.sheetType === "modal" && root.visible
        z: -1

        Behavior on opacity {
            NumberAnimation {
                duration: tokens.motion.durationStandard
                easing.type: root.visible ? tokens.motion.easingDecelerate : tokens.motion.easingAccelerate
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.dismissible && root.sheetType === "modal"
            onClicked: {
                if (root.dismissible && root.sheetType === "modal") {
                    root.hide();
                }
            }
        }
    }

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.borderRadius
        color: root.backgroundColor
        clip: true

        // Shadow
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: -tokens.shadows.elevation4.keyY
            horizontalOffset: 0
            radius: tokens.shadows.elevation4.keyBlur
            samples: 32
            color: tokens.colors.shadow
            transparentBorder: true
            source: bg
        }
    }

    // Content
    Column {
        id: contentColumn
        anchors.fill: parent
        spacing: 0

        // Drag handle
        Rectangle {
            id: dragHandle
            width: tokens.spacing.space10  // 40
            height: 4
            radius: 2
            color: root.handleColor
            visible: root.showDragHandle
            anchors.top: parent.top
            anchors.topMargin: tokens.spacing.space2
            anchors.horizontalCenter: parent.horizontalCenter

            // Touch area for dragging
            MouseArea {
                id: handleMouseArea
                anchors.fill: parent
                anchors.margins: -tokens.spacing.space2
                enabled: root.dragToDismiss
                drag.target: root
                drag.axis: Drag.YAxis
                drag.minimumY: root.minHeight - root.height
                drag.maximumY: parent ? parent.height - tokens.spacing.space4 : 0
                drag.filterChildren: true
                onPressAndHold: {
                    root.dragging = true;
                    root.dragStartY = mouse.y;
                    root.sheetStartY = root.currentY;
                }
                onReleased: {
                    if (root.dragging) {
                        root.dragging = false;
                        var velocity = 0; // Would need to calculate from drag
                        root.snapToPosition();
                    }
                }
            }
        }

        // Header
        Column {
            id: header
            width: parent.width
            spacing: tokens.spacing.space1
            visible: root.title !== "" || root.subtitle !== ""
            Layout.fillWidth: true

            Text {
                id: titleText
                text: root.title
                font.family: tokens.typography.titleLarge.fontFamily
                font.pixelSize: tokens.typography.titleLarge.fontSize
                font.weight: tokens.typography.titleLarge.fontWeight
                color: tokens.isDark() ? tokens.colors.onSurfaceDark : tokens.colors.onSurface
                visible: root.title !== ""
                anchors.left: parent.left
                anchors.leftMargin: tokens.spacing.componentPadding
                anchors.right: parent.right
                anchors.rightMargin: tokens.spacing.componentPadding
                elide: Text.ElideRight
            }

            Text {
                id: subtitleText
                text: root.subtitle
                font.family: tokens.typography.bodyMedium.fontFamily
                font.pixelSize: tokens.typography.bodyMedium.fontSize
                font.weight: tokens.typography.bodyMedium.fontWeight
                color: tokens.isDark() ? tokens.colors.onSurfaceVariantDark : tokens.colors.onSurfaceVariant
                visible: root.subtitle !== ""
                anchors.left: parent.left
                anchors.leftMargin: tokens.spacing.componentPadding
                anchors.right: parent.right
                anchors.rightMargin: tokens.spacing.componentPadding
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
        }

        // Divider
        Rectangle {
            id: divider
            width: parent.width
            height: tokens.shapes.borderWidthThin
            color: tokens.isDark() ? tokens.colors.outlineVariantDark : tokens.colors.outlineVariant
            visible: (root.title !== "" || root.subtitle !== "") && root.content
        }

        // Custom content
        Loader {
            id: contentLoader
            sourceComponent: root.content
            active: root.content !== null
            width: parent.width
            Layout.fillWidth: true
        }

        // Actions
        Row {
            id: actionsRow
            width: parent.width
            height: tokens.spacing.space6 * 2
            spacing: tokens.spacing.componentGapSm
            visible: root.actions.length > 0
            Layout.alignment: Qt.AlignRight

            Repeater {
                model: root.actions
                delegate: Button {
                    text: modelData.text
                    variant: modelData.variant || (modelData.role === "primary" ? "filled" : "text")
                    enabled: modelData.enabled !== false
                    onClicked: {
                        modelData.onClicked();
                        if (modelData.dismiss !== false) {
                            root.hide();
                        }
                    }
                }
            }
        }
    }

    // Drag handling for the whole sheet
    property real dragThreshold: 50

    function snapToPosition() {
        var parentHeight = parent ? parent.height : 600;
        var threshold = parentHeight * 0.3;

        if (root.currentY < parentHeight - root.height - threshold) {
            // Snap to open
            root.show();
        } else {
            // Snap to closed
            root.hide();
        }
    }

    function show() {
        root.targetY = parent ? parent.height - root.height : 0;
        root.animating = true;
        root.currentY = root.targetY;
    }

    function hide() {
        root.targetY = parent ? parent.height : 0;
        root.animating = true;
        root.currentY = root.targetY;
    }

    // Animation
    Behavior on currentY {
        SpringAnimation {
            spring: tokens.motion.springStandard.damping
            spring: tokens.motion.springStandard.stiffness
            onStopped: {
                root.animating = false;
                if (root.currentY >= (parent ? parent.height : 0)) {
                    root.visible = false;
                    root.closed();
                }
            }
        }
    }

    // Escape key
    focus: true
    Keys.onEscapePressed: {
        if (root.dismissible) {
            root.hide();
        }
    }

    signal closed()
}