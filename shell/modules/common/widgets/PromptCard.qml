import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

// The frame both prompt cards share: icon, title, subtitle and a button that
// opens the full window.
Rectangle {
    id: root

    property string icon: ""
    property string symbol: ""
    property string title
    property string subtitle
    property bool danger: false
    default property alias content: contentColumn.data

    signal expand

    implicitHeight: layout.implicitHeight + 24
    radius: Appearance.rounding.normal
    color: root.danger ? Appearance.m3colors.m3errorContainer : Appearance.m3colors.m3surfaceContainerHigh
    border.width: 1
    border.color: root.danger ? Appearance.colors.colError : Appearance.m3colors.m3outlineVariant

    ColumnLayout {
        id: layout
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            AppIcon {
                visible: root.icon !== ""
                source: root.icon
                implicitSize: 32
            }
            MaterialSymbol {
                visible: root.icon === ""
                text: root.symbol
                iconSize: 28
                color: root.danger ? Appearance.colors.colError : Appearance.colors.colSecondary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    Layout.fillWidth: true
                    text: root.title
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnLayer3
                    elide: Text.ElideRight
                }
                StyledText {
                    Layout.fillWidth: true
                    text: root.subtitle
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideMiddle
                }
            }

            RippleButton {
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                onClicked: root.expand()
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "open_in_full"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer3
                }
            }
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: 8
        }
    }
}
