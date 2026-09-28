import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: notificationPopup

    PanelWindow {
        id: root
        readonly property bool prompting: AskpassService.requests.length + FirewallPrompts.prompts.length > 0
        visible: (Notifications.popupList.length > 0 || prompting) && !GlobalStates.screenLocked
        screen: Quickshell.screens.find(s => Config.options.notifications.forceMonitor.enable ? s.name === Config.options.notifications.forceMonitor.name : s.name === Hyprland.focusedMonitor?.name) ?? null

        WlrLayershell.namespace: "quickshell:notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        // A password field needs the keyboard; firewall cards take clicks only,
        // so a game keeps its focus.
        WlrLayershell.keyboardFocus: AskpassService.requests.length > 0 ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusiveZone: 0

        anchors {
            top: true
            right: true
            bottom: true
        }

        mask: Region {
            item: listview.contentItem
            Region {
                item: promptList
            }
        }

        color: "transparent"
        implicitWidth: Appearance.sizes.notificationPopupWidth

        PromptList {
            id: promptList
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 4
                topMargin: 4
            }
            width: parent.width - Appearance.sizes.elevationMargin * 2
        }

        NotificationListView {
            id: listview
            anchors {
                top: promptList.visible ? promptList.bottom : parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: 4
                topMargin: 4
            }
            implicitWidth: parent.width - Appearance.sizes.elevationMargin * 2
            popup: true
        }
    }
}
