pragma Singleton
import QtQuick

QtObject {
    id: typography

    // Font families
    readonly property string fontFamilyBase: "Inter"
    readonly property string fontFamilyFallback: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif"

    // Font weights
    readonly property int weightThin: Font.Thin
    readonly property int weightExtraLight: Font.ExtraLight
    readonly property int weightLight: Font.Light
    readonly property int weightRegular: Font.Normal
    readonly property int weightMedium: Font.Medium
    readonly property int weightSemiBold: Font.DemiBold
    readonly property int weightBold: Font.Bold
    readonly property int weightExtraBold: Font.ExtraBold
    readonly property int weightBlack: Font.Black

    // Display styles
    readonly property var displayLarge: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 57
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 64
        readonly property real letterSpacing: -0.25
    }

    readonly property var displayMedium: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 45
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 52
        readonly property real letterSpacing: 0
    }

    readonly property var displaySmall: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 36
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 44
        readonly property real letterSpacing: 0
    }

    // Headline styles
    readonly property var headlineLarge: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 32
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 40
        readonly property real letterSpacing: 0
    }

    readonly property var headlineMedium: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 28
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 36
        readonly property real letterSpacing: 0
    }

    readonly property var headlineSmall: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 24
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 32
        readonly property real letterSpacing: 0
    }

    // Title styles
    readonly property var titleLarge: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 22
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 28
        readonly property real letterSpacing: 0
    }

    readonly property var titleMedium: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 16
        readonly property int fontWeight: typography.weightMedium
        readonly property real lineHeight: 24
        readonly property real letterSpacing: 0.15
    }

    readonly property var titleSmall: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 14
        readonly property int fontWeight: typography.weightMedium
        readonly property real lineHeight: 20
        readonly property real letterSpacing: 0.1
    }

    // Body styles
    readonly property var bodyLarge: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 16
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 24
        readonly property real letterSpacing: 0.5
    }

    readonly property var bodyMedium: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 14
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 20
        readonly property real letterSpacing: 0.25
    }

    readonly property var bodySmall: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 12
        readonly property int fontWeight: typography.weightRegular
        readonly property real lineHeight: 16
        readonly property real letterSpacing: 0.4
    }

    // Label styles
    readonly property var labelLarge: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 14
        readonly property int fontWeight: typography.weightMedium
        readonly property real lineHeight: 20
        readonly property real letterSpacing: 0.1
    }

    readonly property var labelMedium: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 12
        readonly property int fontWeight: typography.weightMedium
        readonly property real lineHeight: 16
        readonly property real letterSpacing: 0.5
    }

    readonly property var labelSmall: QtObject {
        readonly property string fontFamily: typography.fontFamilyBase
        readonly property int fontSize: 11
        readonly property int fontWeight: typography.weightMedium
        readonly property real lineHeight: 16
        readonly property real letterSpacing: 0.5
    }

    // Helper to apply typography style to a Text element
    function applyStyle(textElement, styleName) {
        var style = typography[styleName];
        if (style) {
            textElement.font.family = style.fontFamily;
            textElement.font.pixelSize = style.fontSize;
            textElement.font.weight = style.fontWeight;
            textElement.lineHeight = style.lineHeight;
            textElement.letterSpacing = style.letterSpacing;
        }
    }

    // Get style by name
    function getStyle(name) {
        return typography[name];
    }
}