pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root
    readonly property bool active: Config.ready && Config.options.background.mode === "matrix"

    // A config file reload flips these settings for a moment; starting on every flip kills the process mid-start.
    onActiveChanged: settle.restart()

    Timer {
        id: settle
        interval: 500
        onTriggered: rain.running = root.active
    }

    Process {
        id: rain
        command: [Config.options.background.matrixCommand]
    }
}
