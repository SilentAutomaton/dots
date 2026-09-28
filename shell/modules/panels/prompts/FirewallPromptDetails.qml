import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    // Keeps the last prompt while the window closes, so bindings never see null.
    property var prompt: FirewallPrompts.details
    Binding on prompt {
        when: FirewallPrompts.details !== null
        value: FirewallPrompts.details
        restoreMode: Binding.RestoreNone
    }
    property string action: Config.options.firewallPrompts.defaultAction

    function close() {
        FirewallPrompts.detailsId = null;
    }

    PromptDialog {
        anchors.fill: parent
        dialogWidth: 640
        onDismiss: root.close()

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            AppIcon {
                visible: source !== ""
                source: FirewallPrompts.appEntry(root.prompt)?.icon ?? ""
                implicitSize: 40
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                WindowDialogTitle {
                    Layout.fillWidth: true
                    text: FirewallPrompts.appName(root.prompt)
                }
                StyledText {
                    Layout.fillWidth: true
                    text: `wants ${FirewallPrompts.destination(root.prompt)}`
                    color: Appearance.colors.colSubtext
                    wrapMode: Text.WrapAnywhere
                }
            }
        }

        StyledFlickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(details.implicitHeight, 260)
            contentHeight: details.implicitHeight
            clip: true

            ColumnLayout {
                id: details
                width: parent.width
                spacing: 6
                PromptDetailRow { label: "Host"; value: root.prompt.dstHost }
                PromptDetailRow { label: "Address"; value: `${root.prompt.dstIp} port ${root.prompt.dstPort}`; monospace: true }
                PromptDetailRow { label: "From"; value: `${root.prompt.srcIp} port ${root.prompt.srcPort}`; monospace: true }
                PromptDetailRow { label: "Executable"; value: root.prompt.path; monospace: true }
                PromptDetailRow { label: "Command line"; value: root.prompt.args.join(" "); monospace: true }
                PromptDetailRow { label: "Directory"; value: root.prompt.cwd; monospace: true }
                PromptDetailRow { label: "Process"; value: `PID ${root.prompt.pid}, user ${root.prompt.user} (${root.prompt.uid})` }
                PromptDetailRow { label: "Steam app"; value: root.prompt.steamAppId }
                PromptDetailRow { label: "MD5"; value: root.prompt.md5; monospace: true }
                PromptDetailRow {
                    label: "Parents"
                    value: root.prompt.tree.map(p => `${p.pid}  ${p.path}`).join("\n")
                    monospace: true
                }
            }
        }

        WindowDialogSeparator {}

        WindowDialogSectionHeader { text: "Action" }
        ConfigSelectionArray {
            options: FirewallPrompts.actions
            currentValue: root.action
            onSelected: value => root.action = value
        }

        WindowDialogSectionHeader { text: "For how long" }
        ConfigSelectionArray {
            options: FirewallPrompts.durations
            currentValue: root.prompt.duration
            onSelected: value => FirewallPrompts.choose(root.prompt.id, "duration", value)
        }

        WindowDialogSectionHeader { text: "Match" }
        ConfigSelectionArray {
            options: root.prompt.targets.map(t => ({ "displayName": t.label, "value": t.key }))
            currentValue: root.prompt.target
            onSelected: value => FirewallPrompts.choose(root.prompt.id, "target", value)
        }

        WindowDialogSectionHeader { text: "Also require" }
        Flow {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: FirewallPrompts.extras
                delegate: SelectionGroupButton {
                    required property var modelData
                    leftmost: true
                    rightmost: true
                    buttonText: modelData.displayName
                    toggled: root.prompt.extras.includes(modelData.value)
                    onClicked: FirewallPrompts.toggleExtra(root.prompt.id, modelData.value)
                }
            }
        }

        WindowDialogButtonRow {
            DialogButton {
                buttonText: "Forget"
                onClicked: FirewallPrompts.dismiss(root.prompt.id)
            }
            Item {
                Layout.fillWidth: true
            }
            DialogButton {
                buttonText: "Close"
                onClicked: root.close()
            }
            DialogButton {
                buttonText: "Apply"
                onClicked: FirewallPrompts.answer(root.prompt.id, root.action)
            }
        }
    }
}
