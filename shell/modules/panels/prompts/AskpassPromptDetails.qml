import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    // Keeps the last request while the window closes, so bindings never see null.
    property var request: AskpassService.details
    Binding on request {
        when: AskpassService.details !== null
        value: AskpassService.details
        restoreMode: Binding.RestoreNone
    }
    readonly property string where: [request.server || request.host, request.description].filter(Boolean).join(" · ")
    readonly property string login: request.login && request.host ? `${request.login}@${request.host}` : ""

    function close() {
        AskpassService.detailsId = null;
    }

    PromptDialog {
        anchors.fill: parent
        dialogWidth: 720
        Component.onCompleted: passwordField.forceActiveFocus()
        onDismiss: root.close()

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            MaterialSymbol {
                text: root.request.dangerous ? "warning" : "key"
                iconSize: 32
                color: root.request.dangerous ? Appearance.colors.colError : Appearance.colors.colSecondary
            }
            WindowDialogTitle {
                Layout.fillWidth: true
                text: root.request.title
            }
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.request.dangerous
            text: "This command is destructive."
            color: Appearance.colors.colError
            font.weight: Font.DemiBold
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            PromptDetailRow { label: "Asked by"; value: root.request.caller || "" }
            PromptDetailRow { label: "Where"; value: root.where }
            PromptDetailRow { label: "Host"; value: root.login; monospace: true }
            PromptDetailRow { label: "Directory"; value: root.request.cwd || ""; monospace: true }
            PromptDetailRow { label: "Run as"; value: root.request.run_as || "root" }
            PromptDetailRow { label: "Prompt"; value: root.request.command ? "" : root.request.prompt }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: !!root.request.command
            WindowDialogSectionHeader {
                Layout.fillWidth: true
                text: "Command"
            }
            RippleButton {
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                onClicked: Quickshell.clipboardText = root.request.command
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "content_copy"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer3
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(commandText.implicitHeight + 16, 320)
            visible: !!root.request.command

            TextArea {
                id: commandText
                text: root.request.command || ""
                readOnly: true
                selectByMouse: true
                wrapMode: TextEdit.WrapAnywhere
                color: Appearance.colors.colOnLayer3
                selectionColor: Appearance.colors.colSecondaryContainer
                selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                font.family: Appearance.font.family.monospace
                font.pixelSize: Appearance.font.pixelSize.small
                background: Rectangle {
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer2
                }
            }
        }

        MaterialTextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Password"
            echoMode: TextInput.Password
            onAccepted: AskpassService.submit(root.request.id, text)
            Keys.onEscapePressed: root.close()
        }

        WindowDialogButtonRow {
            Item {
                Layout.fillWidth: true
            }
            DialogButton {
                buttonText: "Cancel"
                onClicked: AskpassService.cancel(root.request.id)
            }
            DialogButton {
                buttonText: root.request.dangerous ? "Run anyway" : "Authenticate"
                onClicked: AskpassService.submit(root.request.id, passwordField.text)
            }
        }
    }
}
