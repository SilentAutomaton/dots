import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1
    clip: true
    implicitHeight: content.implicitHeight + 20
    property bool collapsed: Persistent.states.sidebar.ports.collapsed
    // Monochrome themes leave only error and success with a hue: green, amber between them, red.
    readonly property var exposureColors: [
        Appearance.m3colors.m3success,
        ColorUtils.mix(Appearance.colors.colError, Appearance.m3colors.m3success, 0.5),
        Appearance.colors.colError
    ]
    readonly property var exposureNames: ["local", "interface", "all interfaces"]
    readonly property int total: ListeningPorts.counts.reduce((sum, count) => sum + count, 0)

    Behavior on implicitHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: "lan"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnLayer1
            }

            StyledText {
                text: "Ports"
                font.pixelSize: Appearance.font.pixelSize.large
                font.family: Appearance.font.family.title
                color: Appearance.colors.colOnLayer1
            }

            StyledText {
                text: ListeningPorts.available ? root.total : "no sudo rule for ss"
                font.pixelSize: Appearance.font.pixelSize.small
                font.family: Appearance.font.family.numbers
                color: ListeningPorts.available ? Appearance.colors.colSubtext : Appearance.colors.colError
            }

            Item {
                Layout.fillWidth: true
            }

            MaterialSymbol {
                text: root.collapsed ? "keyboard_arrow_up" : "keyboard_arrow_down"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnLayer1
            }

            TapHandler {
                onTapped: Persistent.states.sidebar.ports.collapsed = !root.collapsed
            }
        }

        // Share of ports per exposure, widest first.
        Row {
            id: exposureBar
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            spacing: 2

            Repeater {
                model: [2, 1, 0]
                delegate: Rectangle {
                    required property int modelData
                    readonly property int count: ListeningPorts.counts[modelData]
                    visible: count > 0
                    width: root.total > 0 ? (exposureBar.width - 4) * count / root.total : 0
                    height: exposureBar.height
                    radius: height / 2
                    color: root.exposureColors[modelData]
                }
            }
        }

        Row {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: [2, 1, 0]
                delegate: StyledText {
                    required property int modelData
                    text: `${root.exposureNames[modelData]} ${ListeningPorts.counts[modelData]}`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.exposureColors[modelData]
                }
            }
        }

        StyledFlickable {
            visible: !root.collapsed
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(groupList.implicitHeight, 220)
            contentHeight: groupList.implicitHeight
            clip: true

            Column {
                id: groupList
                width: parent.width
                spacing: 6

                Repeater {
                    model: ListeningPorts.groups
                    delegate: RowLayout {
                        id: groupRow
                        required property var modelData
                        width: groupList.width
                        spacing: 8

                        StyledText {
                            Layout.preferredWidth: 110
                            Layout.alignment: Qt.AlignTop
                            text: groupRow.modelData.name
                            elide: Text.ElideRight
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: root.exposureColors[groupRow.modelData.exposure]
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 4

                            Repeater {
                                model: groupRow.modelData.ports
                                delegate: Rectangle {
                                    id: chip
                                    required property var modelData
                                    readonly property color tone: root.exposureColors[modelData.exposure]
                                    implicitWidth: chipText.implicitWidth + 12
                                    implicitHeight: chipText.implicitHeight + 4
                                    radius: Appearance.rounding.full
                                    color: ColorUtils.transparentize(tone, 0.8)

                                    StyledText {
                                        id: chipText
                                        anchors.centerIn: parent
                                        text: `${chip.modelData.port}/${chip.modelData.proto}`
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        font.family: Appearance.font.family.numbers
                                        color: chip.tone
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
