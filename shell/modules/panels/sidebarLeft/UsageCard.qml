import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent
    required property var service
    required property string title
    property var d: service.data

    function barColor(pct) {
        return pct >= 90 ? Appearance.colors.colError : Appearance.colors.colPrimary;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        RowLayout { // Header
            Layout.fillWidth: true
            spacing: 8

            StyledText {
                text: root.title
                font.pixelSize: Appearance.font.pixelSize.large
                font.family: Appearance.font.family.title
                color: Appearance.colors.colOnLayer1
            }

            Rectangle { // Plan badge
                visible: !!root.d.plan
                implicitHeight: planText.implicitHeight + 4
                implicitWidth: planText.implicitWidth + 14
                radius: Appearance.rounding.full
                color: Appearance.colors.colPrimaryContainer
                StyledText {
                    id: planText
                    anchors.centerIn: parent
                    text: (root.d.plan || "").toUpperCase()
                    color: Appearance.colors.colOnPrimaryContainer
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RippleButtonWithIcon {
                materialIcon: "refresh"
                mainText: root.service.loading ? "…" : "Refresh"
                releaseAction: () => root.service.refresh()
            }
        }

        StyledText { // Error
            visible: root.service.error !== ""
            Layout.fillWidth: true
            text: root.service.error
            color: Appearance.colors.colError
            wrapMode: Text.WordWrap
        }

        StyledText { // Placeholder before first load
            visible: !root.service.loaded && root.service.error === "" && !root.service.loading
            Layout.fillWidth: true
            Layout.topMargin: 24
            horizontalAlignment: Text.AlignHCenter
            text: "Press Refresh to load limits"
            color: Appearance.colors.colSubtext
        }

        Repeater { // Usage rows
            model: root.service.loaded ? (root.d.rows || []) : []
            delegate: usageRow
        }

        Loader { // Credits
            active: root.service.loaded && !!root.d.credits
            Layout.fillWidth: true
            visible: active
            sourceComponent: ColumnLayout {
                spacing: 3
                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "Usage credits"
                        color: Appearance.colors.colOnLayer1
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    StyledText {
                        text: root.d.credits.remaining === null ? "unlimited" : `${root.d.credits.cur}${root.d.credits.remaining.toFixed(2)} left`
                        font.family: Appearance.font.family.numbers
                        color: Appearance.colors.colOnLayer1
                    }
                }
                StyledProgressBar {
                    Layout.fillWidth: true
                    valueBarHeight: 6
                    value: Math.min(1, (root.d.credits.pct ?? 0) / 100)
                    highlightColor: root.barColor(root.d.credits.pct ?? 0)
                }
                StyledText {
                    Layout.fillWidth: true
                    text: root.d.credits.limit === null ? `${root.d.credits.cur}${root.d.credits.used.toFixed(2)} used` : `${root.d.credits.cur}${root.d.credits.used.toFixed(2)} of ${root.d.credits.cur}${root.d.credits.limit.toFixed(2)} used`
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        StyledText { // Footer
            visible: root.service.lastRefresh !== ""
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: "Updated " + root.service.lastRefresh
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            opacity: root.service.loading ? 0.5 : 1
        }
    }

    Component {
        id: usageRow
        ColumnLayout {
            required property var modelData
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    text: modelData.label
                    color: Appearance.colors.colOnLayer1
                }
                Item {
                    Layout.fillWidth: true
                }
                StyledText {
                    text: `${Math.round(modelData.pct)}%`
                    font.family: Appearance.font.family.numbers
                    color: modelData.pct >= 90 ? Appearance.colors.colError : Appearance.colors.colOnLayer1
                }
            }

            StyledProgressBar {
                Layout.fillWidth: true
                valueBarHeight: 6
                value: Math.min(1, modelData.pct / 100)
                highlightColor: root.barColor(modelData.pct)
            }

            StyledText {
                visible: text !== ""
                text: modelData.resetStr
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }
    }
}
