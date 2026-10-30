import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Conexus.DesignSystem.Tokens

// Conexus Design System TextField Component
// Variants: filled, outlined
// States: default, hover, focused, disabled, error
// Supports: label, placeholder, helper text, error text, prefix, suffix, leading/trailing icons

TextField {
    id: root

    // Properties
    property string variant: "outlined"       // filled, outlined
    property string label: ""
    property string placeholderText: ""
    property string helperText: ""
    property string errorText: ""
    property bool showCounter: false
    property int maxLength: 0
    property string prefix: ""
    property string suffix: ""
    property string leadingIcon: ""
    property string trailingIcon: ""
    property bool trailingIconClickable: false
    property bool clearButtonEnabled: false
    property bool passwordVisible: false
    property real borderRadius: tokens.shapes.textFieldRadius
    property real borderWidth: tokens.shapes.borderWidthOutline
    property real paddingHorizontal: tokens.spacing.componentPadding
    property real paddingVertical: tokens.spacing.componentPaddingSm
    property real labelGap: tokens.spacing.space1
    property real helperGap: tokens.spacing.space1

    // Internal state
    property bool hasError: root.errorText !== "" && root.errorText !== undefined
    property bool hasFocus: root.activeFocus
    property bool hovered: root.containsMouse
    property bool showPassword: root.echoMode === TextField.Password && root.passwordVisible

    // Accessibility
    accessible.name: root.label || root.placeholderText || "Text field"
    accessible.description: root.helperText || (root.hasError ? root.errorText : "")
    accessible.role: Accessible.EditableText
    accessible.focusable: root.enabled
    accessible.readOnly: root.readOnly
    accessible.required: root.required

    // Colors
    property color containerColor: getContainerColor()
    property color labelColor: getLabelColor()
    property color inputColor: getInputColor()
    property color placeholderColor: getPlaceholderColor()
    property color helperColor: getHelperColor()
    property color borderColor: getBorderColor()
    property color iconColor: getIconColor()
    property color counterColor: getCounterColor()

    function getContainerColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.surfaceHCDark : c.surfaceHC) :
                          (isDark ? c.surfaceContainerHighestDark : c.surfaceContainerHigh);
        }

        if (root.variant === "filled") {
            return isDark ? c.surfaceContainerHighDark : c.surfaceContainerHigh;
        }
        return isDark ? c.surfaceDark : c.surface;
    }

    function getLabelColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                          (isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant);
        }

        if (root.hasError) {
            return isDark ? c.errorDark : c.error;
        }
        if (hasFocus) {
            return isDark ? c.primaryDark : c.primary;
        }
        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    function getInputColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                          (isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant);
        }
        return isDark ? c.onSurfaceDark : c.onSurface;
    }

    function getPlaceholderColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                      (isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant);
    }

    function getHelperColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (root.hasError) {
            return isDark ? c.errorDark : c.error;
        }
        return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                      (isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant);
    }

    function getBorderColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.outlineHCDark : c.outlineHC) :
                          (isDark ? c.outlineVariantDark : c.outlineVariant);
        }

        if (root.hasError) {
            return isDark ? c.errorDark : c.error;
        }
        if (hasFocus) {
            return isDark ? c.primaryDark : c.primary;
        }
        if (hovered) {
            return isDark ? c.outlineDark : c.outline;
        }
        return isDark ? c.outlineVariantDark : c.outlineVariant;
    }

    function getIconColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        if (!enabled) {
            return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                          (isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant);
        }

        if (hasFocus) {
            return isDark ? c.primaryDark : c.primary;
        }
        return isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant;
    }

    function getCounterColor() {
        var isDark = tokens.isDark();
        var isHC = tokens.isHighContrast();
        var c = tokens.colors;

        var currentLength = text.length;
        if (maxLength > 0 && currentLength >= maxLength) {
            return isDark ? c.errorDark : c.error;
        }
        return isHC ? (isDark ? c.onSurfaceHCDark : c.onSurfaceHC) :
                      (isDark ? c.onSurfaceVariantDark : c.onSurfaceVariant);
    }

    // Visual
    background: Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.borderRadius
        color: root.containerColor
        border.color: root.borderColor
        border.width: (root.variant === "outlined" || root.hasFocus) ? root.borderWidth : 0

        // Focus ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: root.borderRadius + 2
            color: "transparent"
            border.color: root.hasError ? (tokens.isDark() ? tokens.colors.errorDark : tokens.colors.error)
                                        : (tokens.isDark() ? tokens.colors.primaryDark : tokens.colors.primary)
            border.width: 2
            opacity: root.hasFocus && root.enabled ? 1 : 0
            visible: root.hasFocus && root.enabled
            Behavior on opacity {
                NumberAnimation { duration: tokens.motion.durationShort }
            }
        }
    }

    // Label
    Label {
        id: floatingLabel
        text: root.label
        font.family: tokens.typography.labelLarge.fontFamily
        font.pixelSize: root.hasFocus || root.text.length > 0 ? tokens.typography.labelSmall.fontSize : tokens.typography.bodyMedium.fontSize
        font.weight: tokens.typography.labelLarge.fontWeight
        color: root.labelColor
        opacity: root.label ? 1 : 0
        visible: root.label !== ""
        x: root.paddingHorizontal + (root.leadingIcon ? tokens.spacing.iconSizeMd + tokens.spacing.iconGap : 0) + (root.prefix ? textMetrics.width(root.prefix) + tokens.spacing.space2 : 0)
        y: root.hasFocus || root.text.length > 0 ? -tokens.spacing.space3 : root.paddingVertical
        Behavior on y {
            NumberAnimation { duration: tokens.motion.durationStandard; easing.type: tokens.motion.easingStandard }
        }
        Behavior on font.pixelSize {
            NumberAnimation { duration: tokens.motion.durationStandard; easing.type: tokens.motion.easingStandard }
        }
    }

    // Placeholder
    placeholderText: root.placeholderText
    placeholderTextColor: root.placeholderColor

    // Text styling
    font.family: tokens.typography.bodyLarge.fontFamily
    font.pixelSize: tokens.typography.bodyLarge.fontSize
    font.weight: tokens.typography.bodyLarge.fontWeight
    color: root.inputColor
    selectionColor: tokens.isDark() ? tokens.colors.primaryContainerDark : tokens.colors.primaryContainer
    selectedTextColor: tokens.isDark() ? tokens.colors.onPrimaryContainerDark : tokens.colors.onPrimaryContainer

    // Padding
    leftPadding: root.paddingHorizontal + (root.leadingIcon ? tokens.spacing.iconSizeMd + tokens.spacing.iconGap : 0) + (root.prefix ? 0 : 0)
    rightPadding: root.paddingHorizontal + (root.trailingIcon || root.clearButtonEnabled || root.showCounter ? tokens.spacing.iconSizeMd + tokens.spacing.iconGap : 0) + (root.suffix ? 0 : 0)
    topPadding: root.label ? tokens.spacing.space3 : root.paddingVertical
    bottomPadding: root.paddingVertical

    // Prefix
    Label {
        id: prefixLabel
        text: root.prefix
        font.family: tokens.typography.bodyLarge.fontFamily
        font.pixelSize: tokens.typography.bodyLarge.fontSize
        font.weight: tokens.typography.bodyLarge.fontWeight
        color: root.iconColor
        visible: root.prefix !== ""
        x: root.leftPadding
        y: (parent.height - height) / 2
    }

    // Leading icon
    Image {
        id: leadingIconItem
        source: root.leadingIcon
        visible: root.leadingIcon !== ""
        width: tokens.spacing.iconSizeMd
        height: tokens.spacing.iconSizeMd
        fillMode: Image.PreserveAspectFit
        color: root.iconColor
        x: root.leftPadding - (root.prefix ? 0 : (tokens.spacing.iconSizeMd + tokens.spacing.iconGap))
        y: (parent.height - height) / 2
    }

    // Trailing icon
    Image {
        id: trailingIconItem
        source: root.trailingIcon
        visible: root.trailingIcon !== "" && !root.clearButtonEnabled && !root.showPassword
        width: tokens.spacing.iconSizeMd
        height: tokens.spacing.iconSizeMd
        fillMode: Image.PreserveAspectFit
        color: root.iconColor
        x: parent.width - root.rightPadding + (root.showCounter ? 0 : tokens.spacing.iconGap)
        y: (parent.height - height) / 2
        MouseArea {
            anchors.fill: parent
            enabled: root.trailingIconClickable && root.enabled
            onClicked: root.trailingIconClicked()
            cursorShape: root.trailingIconClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    // Password visibility toggle
    Image {
        id: passwordToggle
        source: root.showPassword ? "qrc:/icons/visibility_off.svg" : "qrc:/icons/visibility.svg"
        visible: root.echoMode === TextField.Password && !root.trailingIcon && !root.clearButtonEnabled
        width: tokens.spacing.iconSizeMd
        height: tokens.spacing.iconSizeMd
        fillMode: Image.PreserveAspectFit
        color: root.iconColor
        x: parent.width - root.rightPadding
        y: (parent.height - height) / 2
        MouseArea {
            anchors.fill: parent
            onClicked: root.passwordVisible = !root.passwordVisible
            cursorShape: Qt.PointingHandCursor
        }
    }

    // Clear button
    Image {
        id: clearButton
        source: "qrc:/icons/close.svg"
        visible: root.clearButtonEnabled && root.text.length > 0 && root.hasFocus && !root.readOnly
        width: tokens.spacing.iconSizeMd
        height: tokens.spacing.iconSizeMd
        fillMode: Image.PreserveAspectFit
        color: root.iconColor
        x: parent.width - root.rightPadding
        y: (parent.height - height) / 2
        MouseArea {
            anchors.fill: parent
            onClicked: root.text = ""
            cursorShape: Qt.PointingHandCursor
        }
    }

    // Counter
    Label {
        id: counterLabel
        text: root.maxLength > 0 ? (root.text.length + "/" + root.maxLength) : ""
        font.family: tokens.typography.labelSmall.fontFamily
        font.pixelSize: tokens.typography.labelSmall.fontSize
        font.weight: tokens.typography.labelSmall.fontWeight
        color: root.counterColor
        visible: root.showCounter && root.maxLength > 0
        x: parent.width - width - root.paddingHorizontal
        y: parent.height - height - tokens.spacing.space1
    }

    // Helper/Error text
    Label {
        id: helperLabel
        text: root.hasError ? root.errorText : root.helperText
        font.family: tokens.typography.bodySmall.fontFamily
        font.pixelSize: tokens.typography.bodySmall.fontSize
        font.weight: tokens.typography.bodySmall.fontWeight
        color: root.helperColor
        visible: (root.helperText !== "" || root.hasError) && !root.hasFocus
        x: root.paddingHorizontal
        y: parent.height + root.helperGap
        wrapMode: Text.WordWrap
        width: parent.width - root.paddingHorizontal * 2
    }

    Label {
        id: errorLabel
        text: root.errorText
        font.family: tokens.typography.bodySmall.fontFamily
        font.pixelSize: tokens.typography.bodySmall.fontSize
        font.weight: tokens.typography.bodySmall.fontWeight
        color: tokens.isDark() ? tokens.colors.errorDark : tokens.colors.error
        visible: root.hasError && root.hasFocus
        x: root.paddingHorizontal
        y: parent.height + root.helperGap
        wrapMode: Text.WordWrap
        width: parent.width - root.paddingHorizontal * 2
    }

    // Input method hints
    inputMethodHints: root.echoMode === TextField.Password ? Qt.ImhHiddenText | Qt.ImhNoPredictiveText : Qt.ImhNone

    // Signal for trailing icon click
    signal trailingIconClicked()

    // Cursor
    cursorShape: root.enabled ? Qt.IBeamCursor : Qt.ForbiddenCursor
}