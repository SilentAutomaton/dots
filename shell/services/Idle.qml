pragma Singleton
import qs
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    property alias inhibit: idleInhibitor.enabled
    inhibit: false

    Connections {
        target: Persistent
        function onReadyChanged() {
            if (!Persistent.isNewHyprlandInstance) {
                root.inhibit = Persistent.states.idle.inhibit;
            } else {
                Persistent.states.idle.inhibit = root.inhibit;
            }
        }
    }

    function toggleInhibit(active = null) {
        if (active !== null) {
            root.inhibit = active;
        } else {
            root.inhibit = !root.inhibit;
        }
        Persistent.states.idle.inhibit = root.inhibit;
    }

    property bool lockScreenOff: false

    function wakeScreen() {
        if (lockScreenOff) {
            Quickshell.execDetached(["hyprctl", "dispatch", 'hl.dsp.dpms({ action = "enable" })']);
            lockScreenOff = false;
        }
        if (GlobalStates.screenLocked) root.startScreenOffTimer();
    }

    function startScreenOffTimer() {
        if (Config.options.lock.screenOffDelay > 0) lockDpmsTimer.restart();
    }

    Timer {
        id: lockDpmsTimer
        interval: Config.options.lock.screenOffDelay * 1000
        onTriggered: {
            Quickshell.execDetached(["hyprctl", "dispatch", 'hl.dsp.dpms({ action = "disable" })']);
            root.lockScreenOff = true;
        }
    }

    Connections {
        target: GlobalStates
        function onScreenLockedChanged() {
            if (GlobalStates.screenLocked) {
                root.startScreenOffTimer();
            } else {
                lockDpmsTimer.stop();
                Quickshell.execDetached(["hyprctl", "dispatch", 'hl.dsp.dpms({ action = "enable" })']);
            }
        }
    }

    IdleInhibitor {
        id: idleInhibitor
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            anchors {
                right: true
                bottom: true
            }
            // Make it not interactable
            mask: Region {
                item: null
            }
        }
    }
}
