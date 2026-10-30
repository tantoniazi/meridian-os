pragma Singleton
import QtQuick
import Conexus.DesignSystem.Tokens

// Conexus Design System Theme
// Central theme configuration for light, dark, and high contrast modes

QtObject {
    id: theme

    // Theme mode
    property string mode: "system"            // light, dark, highContrast, system
    property string accentColor: "#0066CC"    // Primary accent color
    property string accentColorDark: "#A6C8F0"

    // Resolved theme (computed from mode)
    readonly property string resolvedMode: getResolvedMode()

    function getResolvedMode() {
        if (theme.mode === "system") {
            // In a real app, this would check system theme
            // For now, default to light
            return "light";
        }
        return theme.mode;
    }

    readonly property bool isDark: theme.resolvedMode === "dark"
    readonly property bool isHighContrast: theme.resolvedMode === "highContrast"
    readonly property bool isLight: theme.resolvedMode === "light"

    // Color scheme
    property var colorScheme: getColorScheme()

    function getColorScheme() {
        var c = tokens.colors;
        var isDark = theme.isDark;
        var isHC = theme.isHighContrast;

        if (isHC && isDark) {
            return {
                primary: c.primaryHCDark,
                onPrimary: c.onPrimaryHCDark,
                primaryContainer: c.primaryHCDark,
                onPrimaryContainer: c.onPrimaryHCDark,
                secondary: c.primaryHCDark,
                onSecondary: c.onPrimaryHCDark,
                secondaryContainer: c.primaryHCDark,
                onSecondaryContainer: c.onPrimaryHCDark,
                tertiary: c.primaryHCDark,
                onTertiary: c.onPrimaryHCDark,
                tertiaryContainer: c.primaryHCDark,
                onTertiaryContainer: c.onPrimaryHCDark,
                error: c.errorHCDark,
                onError: c.onErrorHCDark,
                errorContainer: c.errorHCDark,
                onErrorContainer: c.onErrorHCDark,
                warning: c.warningContainerDark,
                onWarning: c.onWarningContainerDark,
                warningContainer: c.warningContainerDark,
                onWarningContainer: c.onWarningContainerDark,
                success: c.successHCDark,
                onSuccess: c.onSuccessHCDark,
                successContainer: c.successHCDark,
                onSuccessContainer: c.onSuccessHCDark,
                surface: c.surfaceHCDark,
                onSurface: c.onSurfaceHCDark,
                surfaceDim: c.surfaceHCDark,
                surfaceBright: c.surfaceHCDark,
                surfaceContainerLowest: c.surfaceHCDark,
                surfaceContainerLow: c.surfaceHCDark,
                surfaceContainer: c.surfaceHCDark,
                surfaceContainerHigh: c.surfaceHCDark,
                surfaceContainerHighest: c.surfaceHCDark,
                background: c.backgroundHCDark,
                onBackground: c.onBackgroundHCDark,
                outline: c.outlineHCDark,
                outlineVariant: c.outlineVariantHCDark,
                inverseSurface: c.inverseSurfaceHCDark,
                inverseOnSurface: c.inverseOnSurfaceHCDark,
                inversePrimary: c.inversePrimaryHCDark,
                surfaceTint: c.primaryHCDark,
                shadow: c.shadowDark,
                scrim: c.scrimDark,
            };
        } else if (isHC) {
            return {
                primary: c.primaryHC,
                onPrimary: c.onPrimaryHC,
                primaryContainer: c.primaryHC,
                onPrimaryContainer: c.onPrimaryHC,
                secondary: c.primaryHC,
                onSecondary: c.onPrimaryHC,
                secondaryContainer: c.primaryHC,
                onSecondaryContainer: c.onPrimaryHC,
                tertiary: c.primaryHC,
                onTertiary: c.onPrimaryHC,
                tertiaryContainer: c.primaryHC,
                onTertiaryContainer: c.onPrimaryHC,
                error: c.errorHC,
                onError: c.onErrorHC,
                errorContainer: c.errorHC,
                onErrorContainer: c.onErrorHC,
                warning: c.warningContainer,
                onWarning: c.onWarningContainer,
                warningContainer: c.warningContainer,
                onWarningContainer: c.onWarningContainer,
                success: c.successContainer,
                onSuccess: c.onSuccessContainer,
                successContainer: c.successContainer,
                onSuccessContainer: c.onSuccessContainer,
                surface: c.surfaceHC,
                onSurface: c.onSurfaceHC,
                surfaceDim: c.surfaceHC,
                surfaceBright: c.surfaceHC,
                surfaceContainerLowest: c.surfaceHC,
                surfaceContainerLow: c.surfaceHC,
                surfaceContainer: c.surfaceHC,
                surfaceContainerHigh: c.surfaceHC,
                surfaceContainerHighest: c.surfaceHC,
                background: c.backgroundHC,
                onBackground: c.onBackgroundHC,
                outline: c.outlineHC,
                outlineVariant: c.outlineVariantHC,
                inverseSurface: c.inverseSurfaceHC,
                inverseOnSurface: c.inverseOnSurfaceHC,
                inversePrimary: c.inversePrimaryHCDark,
                surfaceTint: c.primaryHC,
                shadow: c.shadow,
                scrim: c.scrim,
            };
        } else if (isDark) {
            return {
                primary: c.primaryDark,
                onPrimary: c.onPrimaryDark,
                primaryContainer: c.primaryContainerDark,
                onPrimaryContainer: c.onPrimaryContainerDark,
                secondary: c.secondaryDark,
                onSecondary: c.onSecondaryDark,
                secondaryContainer: c.secondaryContainerDark,
                onSecondaryContainer: c.onSecondaryContainerDark,
                tertiary: c.tertiaryDark,
                onTertiary: c.onTertiaryDark,
                tertiaryContainer: c.tertiaryContainerDark,
                onTertiaryContainer: c.onTertiaryContainerDark,
                error: c.errorDark,
                onError: c.onErrorDark,
                errorContainer: c.errorContainerDark,
                onErrorContainer: c.onErrorContainerDark,
                warning: c.warningContainerDark,
                onWarning: c.onWarningContainerDark,
                warningContainer: c.warningContainerDark,
                onWarningContainer: c.onWarningContainerDark,
                success: c.successContainerDark,
                onSuccess: c.onSuccessContainerDark,
                successContainer: c.successContainerDark,
                onSuccessContainer: c.onSuccessContainerDark,
                surface: c.surfaceDark,
                onSurface: c.onSurfaceDark,
                surfaceDim: c.surfaceDimDark,
                surfaceBright: c.surfaceBrightDark,
                surfaceContainerLowest: c.surfaceContainerLowestDark,
                surfaceContainerLow: c.surfaceContainerLowDark,
                surfaceContainer: c.surfaceContainerDark,
                surfaceContainerHigh: c.surfaceContainerHighDark,
                surfaceContainerHighest: c.surfaceContainerHighestDark,
                background: c.backgroundDark,
                onBackground: c.onBackgroundDark,
                outline: c.outlineDark,
                outlineVariant: c.outlineVariantDark,
                inverseSurface: c.inverseSurfaceDark,
                inverseOnSurface: c.inverseOnSurfaceDark,
                inversePrimary: c.inversePrimaryDark,
                surfaceTint: c.surfaceTintDark,
                shadow: c.shadowDark,
                scrim: c.scrimDark,
            };
        } else {
            return {
                primary: c.primary,
                onPrimary: c.onPrimary,
                primaryContainer: c.primaryContainer,
                onPrimaryContainer: c.onPrimaryContainer,
                secondary: c.secondary,
                onSecondary: c.onSecondary,
                secondaryContainer: c.secondaryContainer,
                onSecondaryContainer: c.onSecondaryContainer,
                tertiary: c.tertiary,
                onTertiary: c.onTertiary,
                tertiaryContainer: c.tertiaryContainer,
                onTertiaryContainer: c.onTertiaryContainer,
                error: c.error,
                onError: c.onError,
                errorContainer: c.errorContainer,
                onErrorContainer: c.onErrorContainer,
                warning: c.warningContainer,
                onWarning: c.onWarningContainer,
                warningContainer: c.warningContainer,
                onWarningContainer: c.onWarningContainer,
                success: c.successContainer,
                onSuccess: c.onSuccessContainer,
                successContainer: c.successContainer,
                onSuccessContainer: c.onSuccessContainer,
                surface: c.surface,
                onSurface: c.onSurface,
                surfaceDim: c.surfaceDim,
                surfaceBright: c.surfaceBright,
                surfaceContainerLowest: c.surfaceContainerLowest,
                surfaceContainerLow: c.surfaceContainerLow,
                surfaceContainer: c.surfaceContainer,
                surfaceContainerHigh: c.surfaceContainerHigh,
                surfaceContainerHighest: c.surfaceContainerHighest,
                background: c.background,
                onBackground: c.onBackground,
                outline: c.outline,
                outlineVariant: c.outlineVariant,
                inverseSurface: c.inverseSurface,
                inverseOnSurface: c.inverseOnSurface,
                inversePrimary: c.inversePrimary,
                surfaceTint: c.surfaceTint,
                shadow: c.shadow,
                scrim: c.scrim,
            };
        }
    }

    // Typography (same for all themes, but could be customized)
    property var typography: tokens.typography

    // Spacing (same for all themes)
    property var spacing: tokens.spacing

    // Motion (same for all themes, but reduced motion could be a setting)
    property var motion: tokens.motion

    // Shapes (same for all themes)
    property var shapes: tokens.shapes

    // Elevation/Shadows (same for all themes)
    property var elevation: tokens.shadows

    // Z-index (same for all themes)
    property var zIndex: tokens.zIndex

    // Component defaults per theme
    property var componentDefaults: getComponentDefaults()

    function getComponentDefaults() {
        var cs = theme.colorScheme;
        var isDark = theme.isDark;

        return {
            button: {
                filled: {
                    background: cs.primary,
                    text: cs.onPrimary,
                    hover: Qt.lighter(cs.primary, 1.1),
                    pressed: cs.primaryContainer,
                },
                outlined: {
                    background: "transparent",
                    text: cs.primary,
                    border: cs.outline,
                    hover: isDark ? Qt.lighter(cs.surfaceContainerHigh, 1.05) : Qt.darker(cs.surfaceContainerHigh, 1.05),
                    pressed: isDark ? Qt.darker(cs.surfaceContainerHigh, 1.1) : Qt.lighter(cs.surfaceContainerHigh, 1.1),
                },
                tonal: {
                    background: cs.secondaryContainer,
                    text: cs.onSecondaryContainer,
                    hover: Qt.lighter(cs.secondaryContainer, 1.1),
                    pressed: Qt.darker(cs.secondaryContainer, 1.1),
                },
                text: {
                    background: "transparent",
                    text: cs.primary,
                    hover: isDark ? Qt.lighter(cs.surfaceContainerHigh, 1.05) : Qt.darker(cs.surfaceContainerHigh, 1.05),
                    pressed: isDark ? Qt.darker(cs.surfaceContainerHigh, 1.1) : Qt.lighter(cs.surfaceContainerHigh, 1.1),
                },
            },
            card: {
                elevated: {
                    background: cs.surface,
                    shadow: tokens.shadows.elevation1,
                },
                filled: {
                    background: cs.surfaceContainerHigh,
                    shadow: null,
                },
                outlined: {
                    background: cs.surface,
                    border: cs.outline,
                    shadow: null,
                },
            },
            textField: {
                filled: {
                    background: cs.surfaceContainerHigh,
                    border: "transparent",
                    focusBorder: cs.primary,
                },
                outlined: {
                    background: cs.surface,
                    border: cs.outlineVariant,
                    focusBorder: cs.primary,
                },
            },
        };
    }

    // Methods
    function setMode(newMode) {
        theme.mode = newMode;
        theme.colorScheme = getColorScheme();
        theme.componentDefaults = getComponentDefaults();
    }

    function setAccentColor(color, colorDark) {
        theme.accentColor = color;
        if (colorDark) {
            theme.accentColorDark = colorDark;
        }
        // Would need to regenerate color scheme with new accent
    }

    function toggleDarkMode() {
        theme.setMode(theme.isDark ? "light" : "dark");
    }
}