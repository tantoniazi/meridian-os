pragma Singleton
import QtQuick

QtObject {
    id: spacing

    // Base unit: 4dp
    readonly property int baseUnit: 4

    // Spacing scale
    readonly property int space0: 0
    readonly property int space1: 4    // 1 * baseUnit
    readonly property int space2: 8    // 2 * baseUnit
    readonly property int space3: 12   // 3 * baseUnit
    readonly property int space4: 16   // 4 * baseUnit
    readonly property int space5: 20   // 5 * baseUnit
    readonly property int space6: 24   // 6 * baseUnit
    readonly property int space7: 28   // 7 * baseUnit
    readonly property int space8: 32   // 8 * baseUnit
    readonly property int space9: 36   // 9 * baseUnit
    readonly property int space10: 40  // 10 * baseUnit
    readonly property int space12: 48  // 12 * baseUnit
    readonly property int space14: 56  // 14 * baseUnit
    readonly property int space16: 64  // 16 * baseUnit

    // Semantic spacing
    readonly property int spacingXxs: spacing.space1   // 4
    readonly property int spacingXs: spacing.space2    // 8
    readonly property int spacingSm: spacing.space3    // 12
    readonly property int spacingMd: spacing.space4    // 16
    readonly property int spacingLg: spacing.space6    // 24
    readonly property int spacingXl: spacing.space8    // 32
    readonly property int spacingXxl: spacing.space10  // 40
    readonly property int spacingXxxl: spacing.space12 // 48

    // Component-specific spacing
    readonly property int componentPadding: spacing.space4      // 16
    readonly property int componentPaddingSm: spacing.space3    // 12
    readonly property int componentPaddingLg: spacing.space6    // 24
    readonly property int componentGap: spacing.space3          // 12
    readonly property int componentGapSm: spacing.space2        // 8
    readonly property int componentGapLg: spacing.space4        // 16

    // Layout spacing
    readonly property int pagePadding: spacing.space6           // 24
    readonly property int pagePaddingSm: spacing.space4         // 16
    readonly property int sectionGap: spacing.space8            // 32
    readonly property int sectionGapSm: spacing.space6          // 24

    // Inset spacing
    readonly property int insetXs: spacing.space1   // 4
    readonly property int insetSm: spacing.space2   // 8
    readonly property int insetMd: spacing.space3   // 12
    readonly property int insetLg: spacing.space4   // 16
    readonly property int insetXl: spacing.space6   // 24

    // Icon spacing
    readonly property int iconSizeXs: 16
    readonly property int iconSizeSm: 20
    readonly property int iconSizeMd: 24
    readonly property int iconSizeLg: 28
    readonly property int iconSizeXl: 32
    readonly property int iconSizeXxl: 48

    readonly property int iconGap: spacing.space2    // 8
    readonly property int iconGapSm: spacing.space1  // 4
    readonly property int iconGapLg: spacing.space3  // 12

    // Touch target minimum
    readonly property int touchTargetMin: 48

    // Get spacing by multiplier
    function get(multiplier) {
        return multiplier * spacing.baseUnit;
    }

    // Get spacing by semantic name
    function getSemantic(name) {
        return spacing[name];
    }
}