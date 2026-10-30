pragma Singleton
import QtQuick

QtObject {
    id: colors

    // Primary colors - Conexus brand
    readonly property color primary: "#0066CC"
    readonly property color primaryContainer: "#D6E4F0"
    readonly property color onPrimary: "#FFFFFF"
    readonly property color onPrimaryContainer: "#001D3A"

    // Secondary colors
    readonly property color secondary: "#4A6FA5"
    readonly property color secondaryContainer: "#DCE6F2"
    readonly property color onSecondary: "#FFFFFF"
    readonly property color onSecondaryContainer: "#0B2749"

    // Tertiary colors
    readonly property color tertiary: "#6B5B95"
    readonly property color tertiaryContainer: "#E8E0F0"
    readonly property color onTertiary: "#FFFFFF"
    readonly property color onTertiaryContainer: "#24193E"

    // Error colors
    readonly property color error: "#BA1A1A"
    readonly property color errorContainer: "#FFDAD6"
    readonly property color onError: "#FFFFFF"
    readonly property color onErrorContainer: "#410002"

    // Warning colors
    readonly property color warning: "#9E6B00"
    readonly property color warningContainer: "#FFF3CC"
    readonly property color onWarning: "#000000"
    readonly property color onWarningContainer: "#332100"

    // Success colors
    readonly property color success: "#2E7D32"
    readonly property color successContainer: "#D6F5D6"
    readonly property color onSuccess: "#FFFFFF"
    readonly property color onSuccessContainer: "#002E00"

    // Surface colors
    readonly property color surface: "#FEF7FF"
    readonly property color surfaceDim: "#DED8E1"
    readonly property color surfaceBright: "#FEF7FF"
    readonly property color surfaceContainerLowest: "#FFFFFF"
    readonly property color surfaceContainerLow: "#F7EDF4"
    readonly property color surfaceContainer: "#F1E8EE"
    readonly property color surfaceContainerHigh: "#ECE3E9"
    readonly property color surfaceContainerHighest: "#E6DEE4"
    readonly property color onSurface: "#1D1A20"
    readonly property color onSurfaceVariant: "#49454F"

    // Background
    readonly property color background: "#FEF7FF"
    readonly property color onBackground: "#1D1A20"

    // Outline
    readonly property color outline: "#79747E"
    readonly property color outlineVariant: "#CAC4D0"

    // Inverse colors
    readonly property color inverseSurface: "#332E36"
    readonly property color inverseOnSurface: "#F4EFF7"
    readonly property color inversePrimary: "#A6C8F0"

    // Shadow
    readonly property color shadow: "#000000"

    // Scrim
    readonly property color scrim: "#000000"

    // Surface tint
    readonly property color surfaceTint: "#0066CC"

    // Dark theme colors
    readonly property color primaryDark: "#A6C8F0"
    readonly property color primaryContainerDark: "#00346B"
    readonly property color onPrimaryDark: "#001D3A"
    readonly property color onPrimaryContainerDark: "#D6E4F0"

    readonly property color secondaryDark: "#BBCDF0"
    readonly property color secondaryContainerDark: "#2B4A7A"
    readonly property color onSecondaryDark: "#0B2749"
    readonly property color onSecondaryContainerDark: "#DCE6F2"

    readonly property color tertiaryDark: "#D0C0E8"
    readonly property color tertiaryContainerDark: "#403266"
    readonly property color onTertiaryDark: "#24193E"
    readonly property color onTertiaryContainerDark: "#E8E0F0"

    readonly property color errorDark: "#FFB4AB"
    readonly property color errorContainerDark: "#93000A"
    readonly property color onErrorDark: "#690005"
    readonly property color onErrorContainerDark: "#FFDAD6"

    readonly property color warningDark: "#FFD580"
    readonly property color warningContainerDark: "#7A5100"
    readonly property color onWarningDark: "#281900"
    readonly property color onWarningContainerDark: "#FFF3CC"

    readonly property color successDark: "#A5D6A7"
    readonly property color successContainerDark: "#1B5E20"
    readonly property color onSuccessDark: "#002E00"
    readonly property color onSuccessContainerDark: "#D6F5D6"

    readonly property color surfaceDark: "#1A171E"
    readonly property color surfaceDimDark: "#1A171E"
    readonly property color surfaceBrightDark: "#47424D"
    readonly property color surfaceContainerLowestDark: "#141118"
    readonly property color surfaceContainerLowDark: "#231F26"
    readonly property color surfaceContainerDark: "#27232A"
    readonly property color surfaceContainerHighDark: "#332E36"
    readonly property color surfaceContainerHighestDark: "#3E3A42"
    readonly property color onSurfaceDark: "#E5E0E9"
    readonly property color onSurfaceVariantDark: "#CAC4D0"

    readonly property color backgroundDark: "#1A171E"
    readonly property color onBackgroundDark: "#E5E0E9"

    readonly property color outlineDark: "#938F99"
    readonly property color outlineVariantDark: "#49454F"

    readonly property color inverseSurfaceDark: "#E5E0E9"
    readonly property color inverseOnSurfaceDark: "#332E36"
    readonly property color inversePrimaryDark: "#0066CC"

    readonly property color surfaceTintDark: "#A6C8F0"
    readonly property color shadowDark: "#000000"
    readonly property color scrimDark: "#000000"

    // High Contrast colors (Light)
    readonly property color primaryHC: "#0000CC"
    readonly property color onPrimaryHC: "#FFFFFF"
    readonly property color surfaceHC: "#FFFFFF"
    readonly property color onSurfaceHC: "#000000"
    readonly property color backgroundHC: "#FFFFFF"
    readonly property color onBackgroundHC: "#000000"
    readonly property color errorHC: "#CC0000"
    readonly property color onErrorHC: "#FFFFFF"
    readonly property color outlineHC: "#000000"
    readonly property color outlineVariantHC: "#333333"

    // High Contrast colors (Dark)
    readonly property color primaryHCDark: "#99CCFF"
    readonly property color onPrimaryHCDark: "#000000"
    readonly property color surfaceHCDark: "#000000"
    readonly property color onSurfaceHCDark: "#FFFFFF"
    readonly property color backgroundHCDark: "#000000"
    readonly property color onBackgroundHCDark: "#FFFFFF"
    readonly property color errorHCDark: "#FF9999"
    readonly property color onErrorHCDark: "#000000"
    readonly property color outlineHCDark: "#FFFFFF"
    readonly property color outlineVariantHCDark: "#CCCCCC"

    // Helper function to get color by name
    function getColor(name) {
        return colors[name];
    }

    // Check if color exists
    function hasColor(name) {
        return name in colors;
    }
}