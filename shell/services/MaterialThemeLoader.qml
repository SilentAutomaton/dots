pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

// Reads the palette that theme/apply renders and pushes it into Appearance.
// reapplyTheme() must run on startup because singletons load lazily.
Singleton {
    id: root

    function reapplyTheme() {
        themeFileView.reload()
    }

    function applyColors(fileContent) {
        const json = JSON.parse(fileContent)
        for (const key in json) {
            const camelCaseKey = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
            Appearance.m3colors[`m3${camelCaseKey}`] = json[key]
        }
        Appearance.m3colors.darkmode = (Appearance.m3colors.m3background.hslLightness < 0.5)
    }

    Timer {
        id: delayedFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 100
        onTriggered: root.applyColors(themeFileView.text())
    }

    FileView {
        id: themeFileView
        path: Directories.generatedMaterialThemePath
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: root.applyColors(themeFileView.text())
    }
}
