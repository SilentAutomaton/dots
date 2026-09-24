import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

SettingsPage {
    SettingsSection {
        icon: "data_usage"
        title: "Subscription usage"

        SettingsLabel {
            text: "Left sidebar, Super+U"
        }
        ConfigSwitch {
            buttonIcon: "counter_1"
            text: "Claude"
            checked: Config.options.sidebar.usage.showClaude
            onCheckedChanged: Config.options.sidebar.usage.showClaude = checked
        }
        ConfigSwitch {
            buttonIcon: "counter_2"
            text: "Z.ai"
            checked: Config.options.sidebar.usage.showZai
            onCheckedChanged: Config.options.sidebar.usage.showZai = checked
        }
        ConfigSpinBox {
            icon: "autorenew"
            text: "Refresh every (min, 0 for manual)"
            value: Config.options.sidebar.usage.refreshMinutes
            from: 0
            to: 120
            stepSize: 5
            onValueChanged: Config.options.sidebar.usage.refreshMinutes = value
        }
    }

    SettingsSection {
        icon: "toggle_on"
        title: "Quick settings"

        SettingsLabel {
            text: "Right sidebar, Super+N"
        }
        ConfigSelectionArray {
            currentValue: Config.options.sidebar.quickToggles.style
            onSelected: value => Config.options.sidebar.quickToggles.style = value
            options: [
                { "displayName": "Tiles", "icon": "grid_view", "value": "android" },
                { "displayName": "Icons", "icon": "more_horiz", "value": "classic" }
            ]
        }
        ConfigSpinBox {
            enabled: Config.options.sidebar.quickToggles.style === "android"
            icon: "view_column"
            text: "Tile columns"
            value: Config.options.sidebar.quickToggles.android.columns
            from: 3
            to: 8
            stepSize: 1
            onValueChanged: Config.options.sidebar.quickToggles.android.columns = value
        }
        ConfigSwitch {
            buttonIcon: "tune"
            text: "Sliders"
            checked: Config.options.sidebar.quickSliders.enable
            onCheckedChanged: Config.options.sidebar.quickSliders.enable = checked
        }
        ConfigSwitch {
            enabled: Config.options.sidebar.quickSliders.enable
            buttonIcon: "brightness_6"
            text: "Brightness slider"
            checked: Config.options.sidebar.quickSliders.showBrightness
            onCheckedChanged: Config.options.sidebar.quickSliders.showBrightness = checked
        }
        ConfigSwitch {
            enabled: Config.options.sidebar.quickSliders.enable
            buttonIcon: "volume_up"
            text: "Volume slider"
            checked: Config.options.sidebar.quickSliders.showVolume
            onCheckedChanged: Config.options.sidebar.quickSliders.showVolume = checked
        }
        ConfigSwitch {
            enabled: Config.options.sidebar.quickSliders.enable
            buttonIcon: "mic"
            text: "Microphone slider"
            checked: Config.options.sidebar.quickSliders.showMic
            onCheckedChanged: Config.options.sidebar.quickSliders.showMic = checked
        }
        ConfigSwitch {
            buttonIcon: "memory_alt"
            text: "Keep loaded for faster opening"
            checked: Config.options.sidebar.keepRightSidebarLoaded
            onCheckedChanged: Config.options.sidebar.keepRightSidebarLoaded = checked
        }
    }

    SettingsSection {
        icon: "call_to_action"
        title: "Screen corners"

        ConfigSwitch {
            buttonIcon: "open_in_full"
            text: "Open sidebars from the top corners"
            checked: Config.options.sidebar.cornerOpen.enable
            onCheckedChanged: Config.options.sidebar.cornerOpen.enable = checked
        }
        ConfigSwitch {
            enabled: Config.options.sidebar.cornerOpen.enable
            buttonIcon: "mouse"
            text: "Open on hover, without a click"
            checked: Config.options.sidebar.cornerOpen.clickless
            onCheckedChanged: Config.options.sidebar.cornerOpen.clickless = checked
        }
        ConfigSwitch {
            enabled: Config.options.sidebar.cornerOpen.enable
            buttonIcon: "swap_vert"
            text: "Scroll for brightness (left) and volume (right)"
            checked: Config.options.sidebar.cornerOpen.valueScroll
            onCheckedChanged: Config.options.sidebar.cornerOpen.valueScroll = checked
        }
        ConfigSwitch {
            enabled: Config.options.sidebar.cornerOpen.enable
            buttonIcon: "visibility"
            text: "Show the corner areas"
            checked: Config.options.sidebar.cornerOpen.visualize
            onCheckedChanged: Config.options.sidebar.cornerOpen.visualize = checked
        }
        ConfigRow {
            enabled: Config.options.sidebar.cornerOpen.enable
            uniform: true
            ConfigSpinBox {
                icon: "width"
                text: "Width"
                value: Config.options.sidebar.cornerOpen.cornerRegionWidth
                from: 1
                to: 400
                stepSize: 10
                onValueChanged: Config.options.sidebar.cornerOpen.cornerRegionWidth = value
            }
            ConfigSpinBox {
                icon: "height"
                text: "Height"
                value: Config.options.sidebar.cornerOpen.cornerRegionHeight
                from: 1
                to: 40
                stepSize: 1
                onValueChanged: Config.options.sidebar.cornerOpen.cornerRegionHeight = value
            }
        }
    }

    SettingsSection {
        icon: "overview_key"
        title: "Overview"

        ConfigSwitch {
            buttonIcon: "grid_on"
            text: "Workspace grid above the search"
            checked: Config.options.overview.enable
            onCheckedChanged: Config.options.overview.enable = checked
        }
        ConfigRow {
            enabled: Config.options.overview.enable
            uniform: true
            ConfigSpinBox {
                icon: "table_rows"
                text: "Rows"
                value: Config.options.overview.rows
                from: 1
                to: 5
                stepSize: 1
                onValueChanged: Config.options.overview.rows = value
            }
            ConfigSpinBox {
                icon: "view_column"
                text: "Columns"
                value: Config.options.overview.columns
                from: 1
                to: 10
                stepSize: 1
                onValueChanged: Config.options.overview.columns = value
            }
        }
        ConfigSpinBox {
            enabled: Config.options.overview.enable
            icon: "aspect_ratio"
            text: "Workspace size (% of screen)"
            value: Math.round(Config.options.overview.scale * 100)
            from: 5
            to: 40
            stepSize: 1
            onValueChanged: Config.options.overview.scale = value / 100
        }
    }

    SettingsSection {
        icon: "notifications"
        title: "Notifications and indicators"

        ConfigSpinBox {
            icon: "timer"
            text: "Notifications stay for (ms)"
            value: Config.options.notifications.timeout
            from: 1000
            to: 30000
            stepSize: 1000
            onValueChanged: Config.options.notifications.timeout = value
        }
        ConfigSwitch {
            buttonIcon: "monitor"
            text: "Always on one monitor"
            checked: Config.options.notifications.forceMonitor.enable
            onCheckedChanged: Config.options.notifications.forceMonitor.enable = checked
        }
        SettingsTextField {
            enabled: Config.options.notifications.forceMonitor.enable
            icon: "desktop_windows"
            text: "Monitor"
            placeholder: "eDP-1"
            value: Config.options.notifications.forceMonitor.name
            onAccepted: value => Config.options.notifications.forceMonitor.name = value
        }
        ConfigSpinBox {
            icon: "volume_up"
            text: "Volume and brightness popup stays for (ms)"
            value: Config.options.osd.timeout
            from: 200
            to: 5000
            stepSize: 100
            onValueChanged: Config.options.osd.timeout = value
        }
    }
}
