pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root
    readonly property bool active: Config.ready && Config.options.background.mode === "matrix"
    readonly property bool refreshing: refresh.running

    function refreshNews() {
        refresh.running = true;
    }

    Process {
        running: root.active
        command: [Config.options.background.matrixCommand]
    }

    Process {
        id: refresh
        command: ["newsboat", "-x", "reload"]
    }
}
