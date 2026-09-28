import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

PromptCard {
    id: root
    required property var prompt

    icon: FirewallPrompts.appEntry(prompt)?.icon ?? ""
    symbol: "shield"
    title: FirewallPrompts.appName(prompt)
    subtitle: `wants ${FirewallPrompts.destination(prompt)}`
    onExpand: FirewallPrompts.detailsId = prompt.id

    StyledText {
        Layout.fillWidth: true
        text: prompt.path || "no executable"
        font.pixelSize: Appearance.font.pixelSize.smaller
        font.family: Appearance.font.family.monospace
        color: Appearance.colors.colSubtext
        elide: Text.ElideMiddle
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        StyledText {
            Layout.fillWidth: true
            text: FirewallPrompts.choiceSummary(root.prompt)
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
        }
        DialogButton {
            buttonText: "Deny"
            onClicked: FirewallPrompts.answer(root.prompt.id, "deny")
        }
        DialogButton {
            buttonText: "Allow"
            onClicked: FirewallPrompts.answer(root.prompt.id, "allow")
        }
    }
}
