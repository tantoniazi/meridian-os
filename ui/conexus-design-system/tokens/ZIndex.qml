pragma Singleton
import QtQuick

QtObject {
    id: zIndex

    // Base z-index values
    readonly property int base: 0

    // Layer z-indices
    readonly property int layerBackground: 0
    readonly property int layerContent: 100
    readonly property int layerOverlay: 200
    readonly property int layerModal: 300
    readonly property int layerPopover: 400
    readonly property int layerToast: 500
    readonly property int layerTooltip: 600

    // Component-specific z-indices (matching requirements)
    readonly property int dropdown: 1000
    readonly property int sticky: 1100
    readonly property int modal: 1300
    readonly property int popover: 1400
    readonly property int toast: 1500

    // Additional component z-indices
    readonly property int appBar: 100
    readonly property int navigationBar: 100
    readonly property int navigationDrawer: 1200
    readonly property int bottomSheet: 1300
    readonly property int dialog: 1300
    readonly property int snackbar: 1400
    readonly property int fab: 1050
    readonly property int chip: 100
    readonly property int tooltip: 1600
    readonly property int menu: 1400
    readonly property int popoverArrow: 1401
    readonly property int loadingIndicator: 1500
    readonly property int overlay: 1200

    // State modifiers (added to base z-index)
    readonly property int hoverOffset: 10
    readonly property int focusOffset: 20
    readonly property int pressedOffset: 5
    readonly property int draggedOffset: 1000

    // Get z-index by name
    function get(name) {
        return zIndex[name];
    }

    // Get z-index for component with state
    function getWithState(componentName, state) {
        var baseZ = zIndex[componentName] || zIndex.base;
        var offset = 0;

        switch (state) {
            case "hover": offset = zIndex.hoverOffset; break;
            case "focus": offset = zIndex.focusOffset; break;
            case "pressed": offset = zIndex.pressedOffset; break;
            case "dragged": offset = zIndex.draggedOffset; break;
            default: offset = 0;
        }

        return baseZ + offset;
    }

    // Ensure z-index is above another
    function above(baseZ, offset) {
        return baseZ + (offset || 1);
    }

    // Ensure z-index is below another
    function below(baseZ, offset) {
        return baseZ - (offset || 1);
    }
}