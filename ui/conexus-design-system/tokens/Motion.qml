pragma Singleton
import QtQuick

QtObject {
    id: motion

    // Duration tokens (in milliseconds)
    readonly property int durationShort: 100
    readonly property int durationStandard: 200
    readonly property int durationEmphasized: 300
    readonly property int durationLong: 400
    readonly property int durationExtraLong: 500
    readonly property int durationFlip: 600

    // Easing curves
    readonly property var easingStandard: Qt.easing.bezier(0.2, 0, 0, 1)
    readonly property var easingEmphasized: Qt.easing.bezier(0.2, 0, 0, 1)
    readonly property var easingDecelerate: Qt.easing.bezier(0, 0, 0.2, 1)
    readonly property var easingAccelerate: Qt.easing.bezier(0.4, 0, 1, 1)
    readonly property var easingLinear: Qt.easing.linear
    readonly property var easingEaseInOut: Qt.easing.inOutQuad
    readonly property var easingEaseOut: Qt.easing.outQuad
    readonly property var easingEaseIn: Qt.easing.inQuad

    // Spring configurations
    readonly property var springStandard: QtObject {
        readonly property real damping: 0.8
        readonly property real stiffness: 120
        readonly property real mass: 1
    }

    readonly property var springBouncy: QtObject {
        readonly property real damping: 0.6
        readonly property real stiffness: 150
        readonly property real mass: 1
    }

    readonly property var springStiff: QtObject {
        readonly property real damping: 0.9
        readonly property real stiffness: 200
        readonly property real mass: 1
    }

    readonly property var springGentle: QtObject {
        readonly property real damping: 1
        readonly property real stiffness: 80
        readonly property real mass: 1
    }

    // Transition types
    readonly property var transitionFade: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingStandard
    }

    readonly property var transitionSlideUp: QtObject {
        readonly property int duration: motion.durationEmphasized
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var transitionSlideDown: QtObject {
        readonly property int duration: motion.durationEmphasized
        readonly property var easing: motion.easingAccelerate
    }

    readonly property var transitionScale: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingStandard
    }

    readonly property var transitionFlip: QtObject {
        readonly property int duration: motion.durationFlip
        readonly property var easing: motion.easingStandard
    }

    readonly property var transitionExpand: QtObject {
        readonly property int duration: motion.durationEmphasized
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var transitionCollapse: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingAccelerate
    }

    // Component-specific transitions
    readonly property var buttonPress: QtObject {
        readonly property int duration: motion.durationShort
        readonly property var easing: motion.easingStandard
    }

    readonly property var buttonRelease: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var checkboxToggle: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingStandard
    }

    readonly property var switchToggle: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingStandard
    }

    readonly property var dialogEnter: QtObject {
        readonly property int duration: motion.durationEmphasized
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var dialogExit: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingAccelerate
    }

    readonly property var bottomSheetEnter: QtObject {
        readonly property int duration: motion.durationEmphasized
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var bottomSheetExit: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingAccelerate
    }

    readonly property var toastEnter: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var toastExit: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingAccelerate
    }

    readonly property var snackbarEnter: QtObject {
        readonly property int duration: motion.durationEmphasized
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var snackbarExit: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingAccelerate
    }

    readonly property var navigationEnter: QtObject {
        readonly property int duration: motion.durationEmphasized
        readonly property var easing: motion.easingDecelerate
    }

    readonly property var navigationExit: QtObject {
        readonly property int duration: motion.durationStandard
        readonly property var easing: motion.easingAccelerate
    }

    // Reduced motion (for accessibility)
    readonly property var reduced: QtObject {
        readonly property int duration: 0
        readonly property var easing: motion.easingLinear
    }

    // Get duration by name
    function getDuration(name) {
        return motion[name];
    }

    // Get transition by name
    function getTransition(name) {
        return motion[name];
    }

    // Get spring config by name
    function getSpring(name) {
        return motion[name];
    }

    // Check if reduced motion is enabled (should be bound to system setting)
    readonly property bool reducedMotionEnabled: false

    // Get appropriate duration based on reduced motion setting
    function getAdjustedDuration(normalDuration) {
        return reducedMotionEnabled ? 0 : normalDuration;
    }
}