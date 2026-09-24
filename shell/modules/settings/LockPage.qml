import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

SettingsPage {
    SettingsSection {
        icon: "lock"
        title: "Lock screen"

        ConfigSwitch {
            buttonIcon: "swap_horiz"
            text: "Use Hyprlock instead of the shell lock"
            checked: Config.options.lock.useHyprlock
            onCheckedChanged: Config.options.lock.useHyprlock = checked
        }
        ConfigSwitch {
            buttonIcon: "login"
            text: "Lock right after login"
            checked: Config.options.lock.launchOnStartup
            onCheckedChanged: Config.options.lock.launchOnStartup = checked
        }
        ConfigSpinBox {
            icon: "monitor"
            text: "Turn the screen off after (s, 0 keeps it on)"
            value: Config.options.lock.screenOffDelay
            from: 0
            to: 600
            stepSize: 10
            onValueChanged: Config.options.lock.screenOffDelay = value
        }
    }

    SettingsSection {
        icon: "style"
        title: "Look"

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: "Blur the wallpaper"
            checked: Config.options.lock.blur.enable
            onCheckedChanged: Config.options.lock.blur.enable = checked
        }
        ConfigSwitch {
            buttonIcon: "center_focus_strong"
            text: "Centre the clock"
            checked: Config.options.lock.centerClock
            onCheckedChanged: Config.options.lock.centerClock = checked
        }
        ConfigSwitch {
            buttonIcon: "text_fields"
            text: "Show \"Locked\" under the clock"
            checked: Config.options.lock.showLockedText
            onCheckedChanged: Config.options.lock.showLockedText = checked
        }
        ConfigSwitch {
            buttonIcon: "interests"
            text: "Different shapes for password characters"
            checked: Config.options.lock.materialShapeChars
            onCheckedChanged: Config.options.lock.materialShapeChars = checked
        }
    }

    SettingsSection {
        icon: "shield_lock"
        title: "Security"

        ConfigSwitch {
            buttonIcon: "power_settings_new"
            text: "Ask for the password to power off or restart"
            checked: Config.options.lock.security.requirePasswordToPower
            onCheckedChanged: Config.options.lock.security.requirePasswordToPower = checked
        }
        ConfigSwitch {
            buttonIcon: "key"
            text: "Unlock the keyring with the same password"
            checked: Config.options.lock.security.unlockKeyring
            onCheckedChanged: Config.options.lock.security.unlockKeyring = checked
        }
    }
}
