import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

SettingsPage {
    SettingsSection {
        icon: "toolbar"
        title: "Layout"

        SettingsLabel {
            text: "Position"
        }
        ConfigSelectionArray {
            currentValue: (Config.options.bar.vertical ? 2 : 0) + (Config.options.bar.bottom ? 1 : 0)
            onSelected: value => {
                Config.options.bar.vertical = value >= 2;
                Config.options.bar.bottom = value % 2 === 1;
            }
            options: [
                { "displayName": "Top", "icon": "arrow_upward", "value": 0 },
                { "displayName": "Bottom", "icon": "arrow_downward", "value": 1 },
                { "displayName": "Left", "icon": "arrow_back", "value": 2 },
                { "displayName": "Right", "icon": "arrow_forward", "value": 3 }
            ]
        }
        SettingsLabel {
            text: "Groups"
        }
        ConfigSelectionArray {
            currentValue: Config.options.bar.borderless
            onSelected: value => Config.options.bar.borderless = value
            options: [
                { "displayName": "Pills", "icon": "rounded_corner", "value": false },
                { "displayName": "Separators", "icon": "more_vert", "value": true }
            ]
        }
        ConfigSwitch {
            buttonIcon: "visibility_off"
            text: "Hide until the pointer reaches the edge"
            checked: Config.options.bar.autoHide.enable
            onCheckedChanged: Config.options.bar.autoHide.enable = checked
        }
        ConfigSwitch {
            buttonIcon: "touch_app"
            text: "Show tooltips on click instead of hover"
            checked: Config.options.bar.tooltips.clickToShow
            onCheckedChanged: Config.options.bar.tooltips.clickToShow = checked
        }
    }

    SettingsSection {
        icon: "widgets"
        title: "Buttons"

        ConfigSwitch {
            buttonIcon: "screenshot_region"
            text: "Screenshot region"
            checked: Config.options.bar.utilButtons.showScreenSnip
            onCheckedChanged: Config.options.bar.utilButtons.showScreenSnip = checked
        }
        ConfigSwitch {
            buttonIcon: "document_scanner"
            text: "Copy text from a region"
            checked: Config.options.bar.utilButtons.showOcr
            onCheckedChanged: Config.options.bar.utilButtons.showOcr = checked
        }
        ConfigSwitch {
            buttonIcon: "mic"
            text: "Microphone mute"
            checked: Config.options.bar.utilButtons.showMicToggle
            onCheckedChanged: Config.options.bar.utilButtons.showMicToggle = checked
        }
        ConfigSwitch {
            buttonIcon: "speed"
            text: "Power profile"
            checked: Config.options.bar.utilButtons.showPerformanceProfileToggle
            onCheckedChanged: Config.options.bar.utilButtons.showPerformanceProfileToggle = checked
        }
        ConfigSwitch {
            buttonIcon: "notifications"
            text: "Unread notification count"
            checked: Config.options.bar.indicators.notifications.showUnreadCount
            onCheckedChanged: Config.options.bar.indicators.notifications.showUnreadCount = checked
        }
    }

    SettingsSection {
        icon: "view_week"
        title: "Workspaces"

        ConfigSpinBox {
            icon: "counter_5"
            text: "Workspaces shown"
            value: Config.options.bar.workspaces.shown
            from: 1
            to: 20
            stepSize: 1
            onValueChanged: Config.options.bar.workspaces.shown = value
        }
        ConfigSwitch {
            buttonIcon: "pin"
            text: "Always show numbers"
            checked: Config.options.bar.workspaces.alwaysShowNumbers
            onCheckedChanged: Config.options.bar.workspaces.alwaysShowNumbers = checked
        }
        ConfigSpinBox {
            enabled: !Config.options.bar.workspaces.alwaysShowNumbers
            icon: "timer"
            text: "Numbers appear after holding Super (ms)"
            value: Config.options.bar.workspaces.showNumberDelay
            from: 0
            to: 1000
            stepSize: 50
            onValueChanged: Config.options.bar.workspaces.showNumberDelay = value
        }
        ConfigSwitch {
            buttonIcon: "apps"
            text: "App icons"
            checked: Config.options.bar.workspaces.showAppIcons
            onCheckedChanged: Config.options.bar.workspaces.showAppIcons = checked
        }
        ConfigSwitch {
            enabled: Config.options.bar.workspaces.showAppIcons
            buttonIcon: "colors"
            text: "Tint app icons"
            checked: Config.options.bar.workspaces.monochromeIcons
            onCheckedChanged: Config.options.bar.workspaces.monochromeIcons = checked
        }
    }

    SettingsSection {
        icon: "shelf_auto_hide"
        title: "Tray"

        ConfigSwitch {
            buttonIcon: "keep"
            text: "Pin new tray icons"
            checked: Config.options.tray.invertPinnedItems
            onCheckedChanged: Config.options.tray.invertPinnedItems = checked
        }
        ConfigSwitch {
            buttonIcon: "colors"
            text: "Tint tray icons"
            checked: Config.options.tray.monochromeIcons
            onCheckedChanged: Config.options.tray.monochromeIcons = checked
        }
    }

    SettingsSection {
        icon: "memory"
        title: "Resources"

        ConfigSwitch {
            buttonIcon: "planner_review"
            text: "Always show CPU"
            checked: Config.options.bar.resources.alwaysShowCpu
            onCheckedChanged: Config.options.bar.resources.alwaysShowCpu = checked
        }
        ConfigSwitch {
            buttonIcon: "swap_horiz"
            text: "Always show swap"
            checked: Config.options.bar.resources.alwaysShowSwap
            onCheckedChanged: Config.options.bar.resources.alwaysShowSwap = checked
        }
        ConfigSpinBox {
            icon: "update"
            text: "Update interval (ms)"
            value: Config.options.resources.updateInterval
            from: 500
            to: 10000
            stepSize: 500
            onValueChanged: Config.options.resources.updateInterval = value
        }
    }
}
