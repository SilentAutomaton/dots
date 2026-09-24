import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    PanelWindow {
        id: panelWindow
        visible: GlobalStates.sidebarLeftOpen

        function hide() {
            GlobalStates.sidebarLeftOpen = false
        }

        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0
        implicitWidth: Appearance.sizes.sidebarWidth + Appearance.sizes.elevationMargin
        WlrLayershell.namespace: "quickshell:sidebarLeft"
        // OnDemand, because Exclusive breaks click-outside-to-close on Hyprland.
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        color: "transparent"

        anchors {
            top: true
            left: true
            bottom: true
        }

        mask: Region {
            item: sidebarLeftBackground
        }

        onVisibleChanged: {
            if (visible) {
                GlobalFocusGrab.addDismissable(panelWindow);
            } else {
                GlobalFocusGrab.removeDismissable(panelWindow);
            }
        }
        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                panelWindow.hide();
            }
        }

        StyledRectangularShadow {
            target: sidebarLeftBackground
            radius: sidebarLeftBackground.radius
        }
        Rectangle {
            id: sidebarLeftBackground
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Appearance.sizes.hyprlandGapsOut
            anchors.leftMargin: Appearance.sizes.hyprlandGapsOut
            width: Appearance.sizes.sidebarWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
            height: parent.height - Appearance.sizes.hyprlandGapsOut * 2
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1
            focus: true

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    panelWindow.hide();
                }
            }

            SidebarLeftContent {}
        }
    }

    IpcHandler {
        target: "sidebarLeft"

        function toggle(): void {
            GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen
        }

        function close(): void {
            GlobalStates.sidebarLeftOpen = false
        }

        function open(): void {
            GlobalStates.sidebarLeftOpen = true
        }
    }

    GlobalShortcut {
        name: "sidebarLeftToggle"
        description: "Toggles left sidebar on press"
        onPressed: GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen
    }

    GlobalShortcut {
        name: "sidebarLeftOpen"
        description: "Opens left sidebar on press"
        onPressed: GlobalStates.sidebarLeftOpen = true
    }

    GlobalShortcut {
        name: "sidebarLeftClose"
        description: "Closes left sidebar on press"
        onPressed: GlobalStates.sidebarLeftOpen = false
    }
}
