import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

PromptCard {
    id: root
    required property var alert

    icon: root.alert.appIcon
    symbol: "warning"
    danger: root.alert.urgency === "critical"
    title: root.alert.summary || root.alert.appName
    subtitle: Qt.formatDateTime(new Date(root.alert.time), "HH:mm")
    onExpand: OrcaAlerts.detailsId = root.alert.id

    StyledText {
        Layout.fillWidth: true
        visible: text !== ""
        text: root.alert.body
        font.pixelSize: Appearance.font.pixelSize.small
        color: Appearance.colors.colOnLayer3
        wrapMode: Text.Wrap
        maximumLineCount: 3
        elide: Text.ElideRight
        textFormat: Text.PlainText
    }

    // Orca's button labels are long; they wrap to a new line instead of
    // widening the card.
    Flow {
        Layout.fillWidth: true
        layoutDirection: Qt.RightToLeft
        spacing: 6
        Repeater {
            model: root.alert.buttons ?? []
            delegate: DialogButton {
                required property var modelData
                buttonText: modelData.label
                onClicked: OrcaAlerts.answer(root.alert.id, modelData.index)
            }
        }
        DialogButton {
            visible: !(root.alert.buttons ?? []).length
            buttonText: "Dismiss"
            onClicked: OrcaAlerts.dismiss(root.alert.id)
        }
    }
}
