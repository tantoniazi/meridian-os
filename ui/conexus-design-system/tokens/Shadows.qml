pragma Singleton
import QtQuick

QtObject {
    id: shadows

    // Shadow color (uses token from Colors)
    readonly property color shadowColor: "#000000"

    // Elevation levels (Material Design 3 elevation system)
    // Each level has: ambient, key, and surface shadows

    // Elevation 0 - No shadow
    readonly property var elevation0: QtObject {
        readonly property int level: 0
        readonly property real ambientOpacity: 0
        readonly property real keyOpacity: 0
        readonly property real surfaceOpacity: 0
        readonly property int ambientBlur: 0
        readonly property int keyBlur: 0
        readonly property int surfaceBlur: 0
        readonly property int ambientY: 0
        readonly property int keyY: 0
        readonly property int surfaceY: 0
    }

    // Elevation 1 - Subtle shadow
    readonly property var elevation1: QtObject {
        readonly property int level: 1
        readonly property real ambientOpacity: 0.11
        readonly property real keyOpacity: 0.16
        readonly property real surfaceOpacity: 0.08
        readonly property int ambientBlur: 3
        readonly property int keyBlur: 3
        readonly property int surfaceBlur: 1
        readonly property int ambientY: 1
        readonly property int keyY: 1
        readonly property int surfaceY: 0
    }

    // Elevation 2 - Low elevation
    readonly property var elevation2: QtObject {
        readonly property int level: 2
        readonly property real ambientOpacity: 0.12
        readonly property real keyOpacity: 0.18
        readonly property real surfaceOpacity: 0.1
        readonly property int ambientBlur: 5
        readonly property int keyBlur: 5
        readonly property int surfaceBlur: 1
        readonly property int ambientY: 3
        readonly property int keyY: 3
        readonly property int surfaceY: 0
    }

    // Elevation 3 - Medium elevation
    readonly property var elevation3: QtObject {
        readonly property int level: 3
        readonly property real ambientOpacity: 0.14
        readonly property real keyOpacity: 0.2
        readonly property real surfaceOpacity: 0.12
        readonly property int ambientBlur: 7
        readonly property int keyBlur: 7
        readonly property int surfaceBlur: 2
        readonly property int ambientY: 4
        readonly property int keyY: 4
        readonly property int surfaceY: 1
    }

    // Elevation 4 - High elevation
    readonly property var elevation4: QtObject {
        readonly property int level: 4
        readonly property real ambientOpacity: 0.14
        readonly property real keyOpacity: 0.22
        readonly property real surfaceOpacity: 0.14
        readonly property int ambientBlur: 9
        readonly property int keyBlur: 9
        readonly property int surfaceBlur: 3
        readonly property int ambientY: 6
        readonly property int keyY: 6
        readonly property int surfaceY: 2
    }

    // Elevation 5 - Highest elevation
    readonly property var elevation5: QtObject {
        readonly property int level: 5
        readonly property real ambientOpacity: 0.16
        readonly property real keyOpacity: 0.24
        readonly property real surfaceOpacity: 0.16
        readonly property int ambientBlur: 12
        readonly property int keyBlur: 12
        readonly property int surfaceBlur: 4
        readonly property int ambientY: 8
        readonly property int keyY: 8
        readonly property int surfaceY: 3
    }

    // Semantic elevations
    readonly property var elevationCard: shadows.elevation1
    readonly property var elevationCardHover: shadows.elevation2
    readonly property var elevationCardPressed: shadows.elevation1

    readonly property var elevationButton: shadows.elevation1
    readonly property var elevationButtonHover: shadows.elevation2
    readonly property var elevationButtonPressed: shadows.elevation1

    readonly property var elevationFAB: shadows.elevation3
    readonly property var elevationFABHover: shadows.elevation4
    readonly property var elevationFABPressed: shadows.elevation3

    readonly property var elevationDialog: shadows.elevation4
    readonly property var elevationBottomSheet: shadows.elevation4
    readonly property var elevationDrawer: shadows.elevation3
    readonly property var elevationMenu: shadows.elevation3
    readonly property var elevationPopover: shadows.elevation3
    readonly property var elevationTooltip: shadows.elevation2
    readonly property var elevationSnackbar: shadows.elevation3
    readonly property var elevationToast: shadows.elevation3

    readonly property var elevationAppBar: shadows.elevation2
    readonly property var elevationNavigationBar: shadows.elevation2

    readonly property var elevationModalOverlay: shadows.elevation5

    // Helper to create a drop shadow effect
    function createDropShadow(elevation) {
        return QtObject {
            property color color: shadows.shadowColor
            property real opacity: elevation.keyOpacity
            property int blur: elevation.keyBlur
            property int x: 0
            property int y: elevation.keyY
        };
    }

    // Helper to create layered shadow (ambient + key + surface)
    function createLayeredShadow(elevation) {
        return QtObject {
            property var ambient: QtObject {
                property color color: shadows.shadowColor
                property real opacity: elevation.ambientOpacity
                property int blur: elevation.ambientBlur
                property int x: 0
                property int y: elevation.ambientY
            }
            property var key: QtObject {
                property color color: shadows.shadowColor
                property real opacity: elevation.keyOpacity
                property int blur: elevation.keyBlur
                property int x: 0
                property int y: elevation.keyY
            }
            property var surface: QtObject {
                property color color: shadows.shadowColor
                property real opacity: elevation.surfaceOpacity
                property int blur: elevation.surfaceBlur
                property int x: 0
                property int y: elevation.surfaceY
            }
        };
    }

    // Get elevation by level number
    function getElevation(level) {
        switch (level) {
            case 0: return shadows.elevation0;
            case 1: return shadows.elevation1;
            case 2: return shadows.elevation2;
            case 3: return shadows.elevation3;
            case 4: return shadows.elevation4;
            case 5: return shadows.elevation5;
            default: return shadows.elevation0;
        }
    }

    // Get elevation by semantic name
    function getSemantic(name) {
        return shadows[name];
    }

    // Apply shadow to a QtQuick item (for use with DropShadow effect)
    function applyToItem(item, elevation) {
        if (!item) return;

        // This would be used with a DropShadow effect in QML
        // Example usage:
        // DropShadow {
        //     source: item
        //     color: Shadows.shadowColor
        //     radius: elevation.keyBlur
        //     verticalOffset: elevation.keyY
        //     horizontalOffset: 0
        //     samples: 16
        //     transparentBorder: true
        // }
    }
}