pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

// The agent network kill switch from vpnonly-killswitch. Armed means the
// agents reach loopback only; disarmed means they go out through the tunnel.
Singleton {
    id: root

    property bool armed: false
    property bool busy: toggleProc.running

    function toggle() {
        toggleProc.running = true;
    }

    // The rules directory is world-readable, so the state needs no root.
    Process {
        id: stateProc
        running: true
        command: ["test", "-f", "/etc/opensnitchd/rules/000-ab-killswitch-deny.json"]
        onExited: (exitCode, exitStatus) => root.armed = exitCode === 0
    }

    Process {
        id: toggleProc
        // ~/.local/bin is not on the session PATH.
        command: [`${FileUtils.trimFileProtocol(Directories.home)}/.local/bin/vpnonly-killswitch`, "toggle"]
        onExited: stateProc.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: stateProc.running = true
    }
}
