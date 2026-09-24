import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

SettingsPage {
    SettingsSection {
        icon: "volume_up"
        title: "Sound"

        ConfigSwitch {
            buttonIcon: "hearing"
            text: "Block sudden volume jumps"
            checked: Config.options.audio.protection.enable
            onCheckedChanged: Config.options.audio.protection.enable = checked
        }
        ConfigRow {
            enabled: Config.options.audio.protection.enable
            uniform: true
            ConfigSpinBox {
                icon: "arrow_warm_up"
                text: "Largest step (%)"
                value: Config.options.audio.protection.maxAllowedIncrease
                from: 1
                to: 100
                stepSize: 1
                onValueChanged: Config.options.audio.protection.maxAllowedIncrease = value
            }
            ConfigSpinBox {
                icon: "vertical_align_top"
                text: "Volume limit (%)"
                value: Config.options.audio.protection.maxAllowed
                from: 1
                to: 150
                stepSize: 1
                onValueChanged: Config.options.audio.protection.maxAllowed = value
            }
        }
        ConfigSwitch {
            buttonIcon: "battery_alert"
            text: "Sound on battery warnings"
            checked: Config.options.sounds.battery
            onCheckedChanged: Config.options.sounds.battery = checked
        }
    }

    SettingsSection {
        icon: "battery_android_full"
        title: "Battery"

        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "battery_android_alert"
                text: "Low at (%)"
                value: Config.options.battery.low
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: Config.options.battery.low = value
            }
            ConfigSpinBox {
                icon: "dangerous"
                text: "Critical at (%)"
                value: Config.options.battery.critical
                from: 0
                to: 100
                stepSize: 1
                onValueChanged: Config.options.battery.critical = value
            }
        }
        ConfigSwitch {
            buttonIcon: "bedtime"
            text: "Suspend when the battery runs out"
            checked: Config.options.battery.automaticSuspend
            onCheckedChanged: Config.options.battery.automaticSuspend = checked
        }
        ConfigSpinBox {
            enabled: Config.options.battery.automaticSuspend
            icon: "battery_android_0"
            text: "Suspend at (%)"
            value: Config.options.battery.suspend
            from: 0
            to: 100
            stepSize: 1
            onValueChanged: Config.options.battery.suspend = value
        }
    }

    SettingsSection {
        icon: "nightlight"
        title: "Night light"

        ConfigSwitch {
            buttonIcon: "schedule"
            text: "Follow a schedule"
            checked: Config.options.light.night.automatic
            onCheckedChanged: Config.options.light.night.automatic = checked
        }
        ConfigRow {
            enabled: Config.options.light.night.automatic
            uniform: true
            SettingsTextField {
                icon: "wb_twilight"
                text: "From"
                placeholder: "19:00"
                value: Config.options.light.night.from
                onAccepted: value => Config.options.light.night.from = value
            }
            SettingsTextField {
                icon: "wb_sunny"
                text: "To"
                placeholder: "06:30"
                value: Config.options.light.night.to
                onAccepted: value => Config.options.light.night.to = value
            }
        }
        ConfigSpinBox {
            icon: "thermostat"
            text: "Colour temperature (K)"
            value: Config.options.light.night.colorTemperature
            from: 1200
            to: 6500
            stepSize: 100
            onValueChanged: Config.options.light.night.colorTemperature = value
        }
    }

    SettingsSection {
        icon: "schedule"
        title: "Clock"

        ConfigSelectionArray {
            currentValue: Config.options.time.format
            onSelected: value => Config.options.time.format = value
            options: [
                { "displayName": "24-hour", "value": "hh:mm" },
                { "displayName": "12-hour", "value": "h:mm ap" },
                { "displayName": "12-hour AM/PM", "value": "h:mm AP" }
            ]
        }
        ConfigSwitch {
            buttonIcon: "timer_10"
            text: "Show seconds"
            checked: Config.options.time.secondPrecision
            onCheckedChanged: Config.options.time.secondPrecision = checked
        }
    }

    SettingsSection {
        icon: "screenshot_region"
        title: "Screenshots"

        SettingsTextField {
            icon: "folder"
            text: "Save to"
            placeholder: "Clipboard only"
            value: Config.options.screenSnip.savePath
            onAccepted: value => Config.options.screenSnip.savePath = value
        }
        ConfigSwitch {
            buttonIcon: "draw"
            text: "Annotate in Satty instead of Swappy"
            checked: Config.options.regionSelector.annotation.useSatty
            onCheckedChanged: Config.options.regionSelector.annotation.useSatty = checked
        }
        ConfigSwitch {
            buttonIcon: "select_window"
            text: "Snap the selection to windows"
            checked: Config.options.regionSelector.targetRegions.windows
            onCheckedChanged: Config.options.regionSelector.targetRegions.windows = checked
        }
        ConfigSwitch {
            buttonIcon: "layers"
            text: "Snap the selection to panels"
            checked: Config.options.regionSelector.targetRegions.layers
            onCheckedChanged: Config.options.regionSelector.targetRegions.layers = checked
        }
    }

    SettingsSection {
        icon: "search"
        title: "Launcher"

        ConfigSwitch {
            buttonIcon: "spellcheck"
            text: "Tolerate typos in app names"
            checked: Config.options.search.sloppy
            onCheckedChanged: Config.options.search.sloppy = checked
        }
        SettingsLabel {
            text: "Prefixes"
        }
        ConfigRow {
            uniform: true
            SettingsTextField {
                text: "Clipboard"
                value: Config.options.search.prefix.clipboard
                onAccepted: value => Config.options.search.prefix.clipboard = value
            }
            SettingsTextField {
                text: "Calculator"
                value: Config.options.search.prefix.math
                onAccepted: value => Config.options.search.prefix.math = value
            }
        }
        ConfigRow {
            uniform: true
            SettingsTextField {
                text: "Command"
                value: Config.options.search.prefix.shellCommand
                onAccepted: value => Config.options.search.prefix.shellCommand = value
            }
            SettingsTextField {
                text: "Action"
                value: Config.options.search.prefix.action
                onAccepted: value => Config.options.search.prefix.action = value
            }
        }
    }
}
