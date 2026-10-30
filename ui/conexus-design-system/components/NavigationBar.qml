import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System NavigationBar Component
// For mobile bottom navigation
// Supports: 3-5 destinations, labels, badges, FAB integration

Item {
    id: root

    // Properties
    property var destinations: []             // Array of {label, icon, selectedIcon, badge, enabled}
    property int currentIndex: 0
    property real height: tokens.spacing.space14  // 56
    property real elevation: 2
    property bool showLabels: true
    property bool shiftMode: false            // Expand selected item
    property string fabIconSource: ""         // FAB icon if integrated
    property bool fabExtended: false

    // Accessibility
    accessible.name: "Bottom navigation"
    accessible.role: Accessible.NavigationBar

    // Colors
    property color backgroundColor: getBackgroundColor()
    property color indicatorColor: getIndicatorColor()
    property color selectedColor: getSelectedColor()
    property color unselectedColor: getUnselectedColor()
    property color badgeColor: tokens.colors.error

    function getBackgroundColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.surfaceContainerDark : c.surfaceContainer;
    }

    function getIndicatorColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.primaryContainerDark : c.primaryContainer;
    }

    function getSelectedColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.primaryDark : c.primary;
    }

    function getUnselectedColor() {
        var isDark = tokens.isDark();
        var c = tokens.colors;
        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    // Visual
    width: parent ? parent.width : 400
    height: root.height
    z: tokens.zIndex.navigationBar

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.backgroundColor
        border.width: 0

        // Top border
        Rectangle {
            width: parent.width
            height: tokens.shapes.borderWidthThin
            color: tokens.isDark() ? tokens.colors.outlineVariantDark : tokens.colors.outlineVariant
            anchors.top: parent.top
        }

        // Shadow
        layer.enabled: root.elevation > 0
        layer.effect: DropShadow {
            verticalOffset: -tokens.shadows.getElevation(root.elevation).keyY
            horizontalOffset: 0
            radius: tokens.shadows.getElevation(root.elevation).keyBlur
            samples: 16
            color: tokens.colors.shadow
            transparentBorder: true
            source: bg
        }
    }

    // Navigation items
    Row {
        id: navRow
        anchors.fill: parent
        spacing: 0

        Repeater {
            id: navRepeater
            model: root.destinations.length
            delegate: Item {
                id: navItem
                width: parent.width / root.destinations.length
                height: parent.height

                property bool isSelected: index === root.currentIndex
                property bool hasBadge: modelData.badge && modelData.badge !== ""
                property bool enabled: modelData.enabled !== false

                // Click area
                MouseArea {
                    id: clickArea
                    anchors.fill: parent
                    enabled: root.enabled
                    onClicked: {
                        if (enabled) {
                            root.currentIndex = index;
                            root.destinationClicked(index);
                        }
                    }
                    hoverEnabled: true
                }

                // Accessibility
                Accessible.name: modelData.label
                Accessible.role: Accessible.Button
                Accessible.checked: isSelected
                Accessible.enabled: enabled
                Accessible.onPressAction: {
                    if (enabled) {
                        root.currentIndex = index;
                        root.destinationClicked(index);
                    }
                }

                // Indicator background (for shift mode)
                Rectangle {
                    id: indicator
                    width: root.shiftMode && isSelected ? parent.width : tokens.spacing.iconSizeMd + tokens.spacing.space4
                    height: tokens.spacing.iconSizeMd + tokens.spacing.space4
                    radius: tokens.shapes.buttonRadius
                    color: root.indicatorColor
                    opacity: isSelected ? 1 : 0
                    visible: isSelected
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: tokens.spacing.space2

                    Behavior on width {
                        SpringAnimation {
                            spring: tokens.motion.springStandard.damping
                            spring: tokens.motion.springStandard.stiffness
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: tokens.motion.durationStandard }
                    }
                }

                // Icon
                Image {
                    id: navIcon
                    source: isSelected ? (modelData.selectedIcon || modelData.icon) : modelData.icon
                    width: tokens.spacing.iconSizeMd
                    height: tokens.spacing.iconSizeMd
                    fillMode: Image.PreserveAspectFit
                    color: isSelected ? root.selectedColor : (enabled ? root.unselectedColor : Qt.lighter(root.unselectedColor, 1.5))
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: root.showLabels ? tokens.spacing.space2 : (parent.height - height) / 2

                    Behavior on color {
                        ColorAnimation { duration: tokens.motion.durationStandard }
                    }
                    Behavior on y {
                        NumberAnimation { duration: tokens.motion.durationStandard }
                    }
                }

                // Label
                Text {
                    id: navLabel
                    text: modelData.label
                    font.family: tokens.typography.labelSmall.fontFamily
                    font.pixelSize: tokens.typography.labelSmall.fontSize
                    font.weight: isSelected ? tokens.typography.weightMedium : tokens.typography.weightRegular
                    color: isSelected ? root.selectedColor : (enabled ? root.unselectedColor : Qt.lighter(root.unselectedColor, 1.5))
                    visible: root.showLabels
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: tokens.spacing.space1
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: isSelected ? 1 : (root.showLabels ? 1 : 0)

                    Behavior on opacity {
                        NumberAnimation { duration: tokens.motion.durationStandard }
                    }
                    Behavior on color {
                        ColorAnimation { duration: tokens.motion.durationStandard }
                    }
                    Behavior on font.weight {
                        NumberAnimation { duration: tokens.motion.durationStandard }
                    }
                }

                // Badge
                Rectangle {
                    id: badge
                    width: Math.max(tokens.spacing.iconSizeXs, badgeText.implicitWidth + tokens.spacing.space2)
                    height: tokens.spacing.iconSizeXs
                    radius: tokens.spacing.iconSizeXs / 2
                    color: root.badgeColor
                    visible: hasBadge
                    anchors.top: navIcon.top
                    anchors.right: navIcon.right
                    anchors.margins: -tokens.spacing.space1

                    Text {
                        id: badgeText
                        text: modelData.badge
                        font.family: tokens.typography.labelSmall.fontFamily
                        font.pixelSize: tokens.typography.labelSmall.fontSize
                        font.weight: tokens.typography.weightBold
                        color: tokens.colors.onError
                        anchors.centerIn: parent
                    }
                }

                // Focus ring
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    radius: tokens.shapes.buttonRadius + 2
                    color: "transparent"
                    border.color: tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary
                    border.width: 2
                    opacity: clickArea.pressed && enabled ? 1 : 0
                    visible: clickArea.pressed && enabled
                }
            }
        }

        // FAB space (if integrated)
        Item {
            id: fabSpace
            width: root.fabIconSource ? root.height * 1.5 : 0
            height: parent.height
            visible: root.fabIconSource !== ""
        }
    }

    signal destinationClicked(int index)
}