import qs.services
import qs.modules.common
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property int sidebarPadding: 10
    anchors.fill: parent

    component UsageSlot: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 296
        radius: Appearance.rounding.normal
        color: Appearance.colors.colLayer1
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: root.sidebarPadding
        }
        spacing: root.sidebarPadding

        UsageSlot {
            visible: Config.options.sidebar.usage.showClaude
            UsageCard {
                service: ClaudeLimits
                title: "Claude Usage"
            }
        }

        UsageSlot {
            visible: Config.options.sidebar.usage.showZai
            UsageCard {
                service: ZaiLimits
                title: "Z.ai Usage"
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
