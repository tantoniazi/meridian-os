import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System AppBar Component
// Variants: small, medium, large, centered, scrollable
// Supports: leading/trailing actions, title, subtitle, search, tabs

Item {
    id: root

    // Properties
    property string variant: "medium"         // small, medium, large, centered, scrollable
    property string title: ""
    property string subtitle: ""
    property Component leading: null          // Leading widget (back button, menu, etc.)
    property var leadingActions: []           // Array of {icon, onClicked, tooltip}
    property var trailingActions: []          // Array of {icon, text, onClicked, variant, badge}
    property Component titleComponent: null   // Custom title component
    property real height: getHeight()
    property real elevation: 2
    property bool pinned: false               // Stay fixed on scroll
    property bool scrollable: false           // Collapse on scroll
    property real scrollOffset: 0             // Current scroll offset (0-1)
    property color backgroundColor: getBackgroundColor()
    property color surfaceTintColor: getSurfaceTintColor()

    function getHeight() {
        switch (variant) {
            case "small": return tokens.spacing.space12;      // 48
            case "medium": return tokens.spacing.space14;     // 56
            case "large": return tokens.spacing.space14 * 2;  // 112
            case "centered": return tokens.spacing.space14;   // 56
            case "scrollable": return tokens.spacing.space14 * 2; // 112
            default: return tokens.spacing.space14;
        }
    }

    // Accessibility
    accessible.name: root.title || "App bar"
    accessible.role: Accessible.Header

    // Colors
    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.surfaceDark : c.surface;
    }

    function getSurfaceTintColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.surfaceTintDark : c.surfaceTint;
    }

    // Visual
    width: parent ? parent.width : 400
    height: root.height
    z: tokens.zIndex.appBar
    clip: true

    // Background with surface tint
    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.backgroundColor

        // Surface tint overlay (for elevation)
        Rectangle {
            anchors.fill: parent
            color: root.surfaceTintColor
            opacity: root.elevation > 0 ? Math.min(root.elevation * 0.05, 0.1) : 0
            visible: root.elevation > 0
        }

        // Bottom border
        Rectangle {
            width: parent.width
            height: tokens.shapes.borderWidthThin
            color: tokens.isDark() ? tokens.colors.outlineVariantDark : tokens.colors.outlineVariant
            anchors.bottom: parent.bottom
            opacity: root.elevation > 0 ? 0 : 1
        }

        // Shadow
        layer.enabled: root.elevation > 0
        layer.effect: DropShadow {
            verticalOffset: tokens.shadows.getElevation(root.elevation).keyY
            horizontalOffset: 0
            radius: tokens.shadows.getElevation(root.elevation).keyBlur
            samples: 16
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

        // Status bar spacer (for mobile)
        Rectangle {
            id: statusBarSpacer
            width: parent.width
            height: tokens.spacing.space4  // 16 (approximate status bar height)
            color: "transparent"
            visible: root.variant !== "small" && Qt.platform.os === "android" || Qt.platform.os === "ios"
        }

        // Main app bar row
        Row {
            id: mainRow
            width: parent.width
            height: root.height - statusBarSpacer.height
            spacing: tokens.spacing.componentGapSm

            // Leading
            Loader {
                id: leadingLoader
                sourceComponent: root.leading
                active: root.leading !== null
                width: root.height - statusBarSpacer.height
                height: root.height - statusBarSpacer.height
            }

            // Leading actions (if no custom leading)
            Row {
                id: leadingActionsRow
                spacing: tokens.spacing.space1
                visible: root.leading === null && root.leadingActions.length > 0
                height: parent.height

                Repeater {
                    model: root.leadingActions
                    delegate: Button {
                        id: leadingBtn
                        iconSource: modelData.icon
                        variant: "text"
                        iconSize: tokens.spacing.iconSizeMd
                        paddingHorizontal: tokens.spacing.space2
                        paddingVertical: tokens.spacing.space2
                        onClicked: modelData.onClicked()
                        ToolTip.visible: modelData.tooltip ? true : false
                        ToolTip.text: modelData.tooltip || ""
                    }
                }
            }

            // Title area
            Item {
                id: titleArea
                Layout.fillWidth: true
                height: parent.height
                clip: true

                // Custom title component
                Loader {
                    id: titleComponentLoader
                    sourceComponent: root.titleComponent
                    active: root.titleComponent !== null
                    anchors.centerIn: parent
                }

                // Default title/subtitle
                Column {
                    id: defaultTitleColumn
                    visible: root.titleComponent === null && (root.title !== "" || root.subtitle !== "")
                    anchors.left: parent.left
                    anchors.leftMargin: tokens.spacing.componentPadding
                    anchors.right: parent.right
                    anchors.rightMargin: tokens.spacing.componentPadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: tokens.spacing.space1

                    Text {
                        id: titleText
                        text: root.title
                        font.family: tokens.typography.titleLarge.fontFamily
                        font.pixelSize: tokens.typography.titleLarge.fontSize
                        font.weight: tokens.typography.titleLarge.fontWeight
                        color: tokens.isDark() ? tokens.colors.onSurfaceDark : tokens.colors.onSurface
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        id: subtitleText
                        text: root.subtitle
                        font.family: tokens.typography.bodyMedium.fontFamily
                        font.pixelSize: tokens.typography.bodyMedium.fontSize
                        font.weight: tokens.typography.bodyMedium.fontWeight
                        color: tokens.isDark() ? tokens.colors.onSurfaceVariantDark : tokens.colors.onSurfaceVariant
                        visible: root.subtitle !== ""
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }

                // Centered variant title
                Column {
                    id: centeredTitleColumn
                    visible: root.variant === "centered" && root.titleComponent === null && (root.title !== "" || root.subtitle !== "")
                    anchors.centerIn: parent
                    spacing: tokens.spacing.space1

                    Text {
                        text: root.title
                        font.family: tokens.typography.titleLarge.fontFamily
                        font.pixelSize: tokens.typography.titleLarge.fontSize
                        font.weight: tokens.typography.titleLarge.fontWeight
                        color: tokens.isDark() ? tokens.colors.onSurfaceDark : tokens.colors.onSurface
                    }

                    Text {
                        text: root.subtitle
                        font.family: tokens.typography.bodyMedium.fontFamily
                        font.pixelSize: tokens.typography.bodyMedium.fontSize
                        font.weight: tokens.typography.bodyMedium.fontWeight
                        color: tokens.isDark() ? tokens.colors.onSurfaceVariantDark : tokens.colors.onSurfaceVariant
                        visible: root.subtitle !== ""
                    }
                }
            }

            // Trailing actions
            Row {
                id: trailingActionsRow
                spacing: tokens.spacing.space1
                height: parent.height

                Repeater {
                    model: root.trailingActions
                    delegate: Item {
                        id: trailingItem
                        width: modelData.text ? undefined : (root.height - statusBarSpacer.height)
                        height: parent.height

                        // Action button
                        Button {
                            id: trailingBtn
                            text: modelData.text || ""
                            iconSource: modelData.icon
                            variant: modelData.variant || "text"
                            iconSize: tokens.spacing.iconSizeMd
                            paddingHorizontal: modelData.text ? tokens.spacing.componentPadding : tokens.spacing.space2
                            paddingVertical: tokens.spacing.space2
                            enabled: modelData.enabled !== false
                            onClicked: modelData.onClicked()

                            // Badge
                            property bool hasBadge: modelData.badge && modelData.badge !== ""
                            Badge {
                                id: actionBadge
                                text: modelData.badge || ""
                                visible: trailingItem.hasBadge
                                anchors.top: trailingBtn.top
                                anchors.topMargin: -tokens.spacing.space1
                                anchors.right: trailingBtn.right
                                anchors.rightMargin: -tokens.spacing.space1
                                variant: "dot"
                                colorVariant: "error"
                            }
                        }
                    }
                }
            }
        }

        // Scrollable content (tabs, search, etc.)
        Item {
            id: scrollableContent
            width: parent.width
            height: root.variant === "large" || root.variant === "scrollable" ? root.height - (root.height / 2) - statusBarSpacer.height : 0
            visible: root.variant === "large" || root.variant === "scrollable"
            clip: true

            // This area can be used for tabs, search bar, etc.
            // Content should be provided via a property or child items
        }
    }

    // Scroll handling
    property real collapsedHeight: tokens.spacing.space14 + (Qt.platform.os === "android" || Qt.platform.os === "ios" ? tokens.spacing.space4 : 0)

    function collapse() {
        if (root.scrollable) {
            root.scrollOffset = 1;
        }
    }

    function expand() {
        if (root.scrollable) {
            root.scrollOffset = 0;
        }
    }

    // Methods for external scroll coordination
    function onScroll(yOffset) {
        if (root.scrollable) {
            var maxScroll = root.height - root.collapsedHeight;
            root.scrollOffset = Math.min(Math.max(yOffset / maxScroll, 0), 1);
        }
    }
}