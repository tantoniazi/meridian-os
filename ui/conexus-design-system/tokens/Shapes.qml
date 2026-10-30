pragma Singleton
import QtQuick

QtObject {
    id: shapes

    // Border radius scale (in dp)
    readonly property int radiusNone: 0
    readonly property int radiusExtraSmall: 4
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 16
    readonly property int radiusExtraLarge: 28
    readonly property int radiusFull: 9999

    // Semantic shape names
    readonly property int shapeXs: shapes.radiusExtraSmall
    readonly property int shapeSm: shapes.radiusSmall
    readonly property int shapeMd: shapes.radiusMedium
    readonly property int shapeLg: shapes.radiusLarge
    readonly property int shapeXl: shapes.radiusExtraLarge
    readonly property int shapeFull: shapes.radiusFull

    // Component-specific shapes
    readonly property int buttonRadius: shapes.radiusMedium
    readonly property int buttonRadiusSm: shapes.radiusSmall
    readonly property int buttonRadiusLg: shapes.radiusLarge

    readonly property int cardRadius: shapes.radiusLarge
    readonly property int cardRadiusSm: shapes.radiusMedium
    readonly property int cardRadiusLg: shapes.radiusExtraLarge

    readonly property int chipRadius: shapes.radiusFull
    readonly property int chipRadiusOutlined: shapes.radiusMedium

    readonly property int dialogRadius: shapes.radiusLarge
    readonly property int bottomSheetRadius: shapes.radiusExtraLarge

    readonly property int textFieldRadius: shapes.radiusSmall
    readonly property int textFieldRadiusSm: shapes.radiusExtraSmall

    readonly property int switchRadius: shapes.radiusFull
    readonly property int switchThumbRadius: shapes.radiusFull

    readonly property int sliderRadius: shapes.radiusFull
    readonly property int sliderThumbRadius: shapes.radiusFull

    readonly property int tooltipRadius: shapes.radiusSmall
    readonly property int menuRadius: shapes.radiusMedium
    readonly property int popoverRadius: shapes.radiusMedium

    readonly property int avatarRadius: shapes.radiusFull
    readonly property int avatarRadiusRounded: shapes.radiusMedium

    readonly property int progressRadius: shapes.radiusFull
    readonly property int progressTrackRadius: shapes.radiusFull

    readonly property int tabRadius: shapes.radiusMedium
    readonly property int tabIndicatorRadius: shapes.radiusFull

    readonly property int navigationRadius: shapes.radiusMedium

    readonly property int listItemRadius: shapes.radiusMedium
    readonly property int listItemRadiusSm: shapes.radiusSmall

    readonly property int badgeRadius: shapes.radiusFull
    readonly property int badgeRadiusDot: shapes.radiusFull

    readonly property int dividerRadius: shapes.radiusNone

    readonly property int iconButtonRadius: shapes.radiusFull

    // Border widths
    readonly property int borderWidthNone: 0
    readonly property int borderWidthThin: 1
    readonly property int borderWidthMedium: 2
    readonly property int borderWidthThick: 3

    readonly property int borderWidthOutline: shapes.borderWidthThin
    readonly property int borderWidthOutlineThick: shapes.borderWidthMedium

    // Get radius by name
    function getRadius(name) {
        return shapes[name];
    }

    // Get radius by semantic size
    function getSemantic(size) {
        switch (size) {
            case "xs": return shapes.radiusExtraSmall;
            case "sm": return shapes.radiusSmall;
            case "md": return shapes.radiusMedium;
            case "lg": return shapes.radiusLarge;
            case "xl": return shapes.radiusExtraLarge;
            case "full": return shapes.radiusFull;
            default: return shapes.radiusMedium;
        }
    }

    // Create a rounded rectangle for use in shapes
    function createRoundedRect(radius, borderWidth, borderColor) {
        return QtObject {
            property int radius: radius
            property int borderWidth: borderWidth
            property color borderColor: borderColor
        };
    }
}