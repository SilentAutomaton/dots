import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    implicitWidth: 26
    implicitHeight: 26
    hoverEnabled: true
    // Only a click sends the address lookup out; hovering stays offline.
    onClicked: TunnelStatus.refreshExit()

    function ageText(seconds) {
        if (seconds < 0) return "never";
        if (seconds < 120) return `${seconds} s ago`;
        return `${Math.round(seconds / 60)} min ago`;
    }

    MaterialSymbol {
        anchors.centerIn: parent
        fill: 1
        iconSize: Appearance.font.pixelSize.large
        text: !TunnelStatus.throughTunnel ? "public_off" : TunnelStatus.stale ? "vpn_key_alert" : "vpn_lock"
        color: !TunnelStatus.throughTunnel ? Appearance.colors.colError
            : TunnelStatus.stale ? Appearance.colors.colTertiary : Appearance.colors.colPrimary
    }

    StyledPopup {
        id: popup
        hoverTarget: root

        Column {
            anchors.centerIn: parent
            spacing: 8

            StyledPopupHeaderRow {
                icon: TunnelStatus.throughTunnel ? "vpn_lock" : "public_off"
                label: TunnelStatus.throughTunnel ? "Through the tunnel" : "Not through a tunnel"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "route"
                    label: "Route:"
                    value: TunnelStatus.routeIface || "no route"
                }
                StyledPopupValueRow {
                    icon: "list"
                    label: "Tunnels:"
                    value: TunnelStatus.tunnels.join(", ")
                }
                StyledPopupValueRow {
                    visible: TunnelStatus.throughTunnel
                    icon: "handshake"
                    label: "Handshake:"
                    value: root.ageText(TunnelStatus.handshakeAge)
                }
                StyledPopupValueRow {
                    icon: "language"
                    label: "Exit:"
                    value: TunnelStatus.exitLoading ? "checking…"
                        : TunnelStatus.exitIp === "" ? "click the icon to check"
                        : `${TunnelStatus.exitIp}, ${TunnelStatus.exitCountry}`
                }
            }
        }
    }
}
