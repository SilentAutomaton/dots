import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets

// Goes through the program's get/set commands, so hand edits and comments in its
// config survive. Speeds are percent of the program defaults.
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 4

    readonly property string command: Config.options.background.matrixCommand
    readonly property list<string> keys: ["palette.preset", "rain.fall_speed", "rain.density", "rain.cycle_speed"]
    readonly property real defaultFallSpeed: 0.2
    readonly property real defaultCycleSpeed: 1.2
    property var values: ({})
    property bool loaded: false
    readonly property bool followsTheme: root.values["palette.preset"] === "theme"

    function write(key: string, value: string) {
        const old = root.values[key];
        if (!root.loaded || old === value || Number(old) === Number(value)) return;
        root.values = Object.assign({}, root.values, { [key]: value });
        Quickshell.execDetached([root.command, "set", key, value]);
    }

    // Spin boxes drop a declarative binding once they set their own value, so they are filled here.
    function fill(read) {
        const percent = (key, base) => Math.round(parseFloat(read[key]) / base * 100);
        fallSpeed.value = percent("rain.fall_speed", root.defaultFallSpeed);
        density.value = percent("rain.density", 1);
        flicker.value = percent("rain.cycle_speed", root.defaultCycleSpeed);
        root.loaded = true;
    }

    Process {
        running: true
        command: ["sh", "-c", 'for key in "$@"; do printf "%s=" "$key"; "$0" get "$key" || echo; done', root.command].concat(Array.from(root.keys))
        stdout: StdioCollector {
            onStreamFinished: {
                const read = {};
                for (const line of text.trim().split("\n")) {
                    const at = line.indexOf("=");
                    if (at > 0 && at < line.length - 1) read[line.slice(0, at)] = line.slice(at + 1);
                }
                root.values = read;
                if (Object.keys(read).length === root.keys.length) root.fill(read);
            }
        }
    }

    SettingsLabel {
        visible: !root.loaded
        text: "Rain settings are unavailable: matrix-news-viewer is not installed"
    }
    ConfigSwitch {
        visible: root.loaded
        buttonIcon: "palette"
        text: "Use the theme colours of the bar and terminals"
        checked: root.followsTheme
        onCheckedChanged: {
            if (checked !== root.followsTheme) root.write("palette.preset", checked ? "theme" : "green");
        }
    }
    ConfigSelectionArray {
        visible: root.loaded && !root.followsTheme
        currentValue: root.values["palette.preset"]
        onSelected: preset => root.write("palette.preset", preset)
        options: [
            { "displayName": "Green", "value": "green" },
            { "displayName": "Amber", "value": "amber" },
            { "displayName": "Ice", "value": "ice" },
            { "displayName": "Red", "value": "red" }
        ]
    }
    ConfigSpinBox {
        id: fallSpeed
        visible: root.loaded
        icon: "speed"
        text: "Fall speed (%)"
        from: 25
        to: 400
        stepSize: 25
        onValueChanged: root.write("rain.fall_speed", (value / 100 * root.defaultFallSpeed).toFixed(3))
    }
    ConfigSpinBox {
        id: density
        visible: root.loaded
        icon: "density_medium"
        text: "Columns with rain (%)"
        from: 10
        to: 100
        stepSize: 10
        onValueChanged: root.write("rain.density", (value / 100).toFixed(2))
    }
    ConfigSpinBox {
        id: flicker
        visible: root.loaded
        icon: "shuffle"
        text: "Symbol flicker (%)"
        from: 0
        to: 400
        stepSize: 25
        onValueChanged: root.write("rain.cycle_speed", (value / 100 * root.defaultCycleSpeed).toFixed(3))
    }
}
