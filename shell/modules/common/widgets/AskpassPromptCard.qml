import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

PromptCard {
    id: root
    required property var request

    symbol: request.dangerous ? "warning" : "key"
    danger: request.dangerous
    title: request.title
    subtitle: request.caller ? `${request.caller} asks to run as ${request.run_as || "root"}` : `run as ${request.run_as || "root"}`
    onExpand: AskpassService.detailsId = request.id

    StyledText {
        Layout.fillWidth: true
        visible: text !== ""
        text: root.request.command || root.request.prompt
        font.pixelSize: Appearance.font.pixelSize.smaller
        font.family: Appearance.font.family.monospace
        color: root.danger ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnLayer3
        wrapMode: Text.WrapAnywhere
        maximumLineCount: 3
        elide: Text.ElideRight
    }

    MaterialTextField {
        id: passwordField
        Layout.fillWidth: true
        placeholderText: "Password"
        echoMode: TextInput.Password
        onAccepted: AskpassService.submit(root.request.id, text)
        Keys.onEscapePressed: AskpassService.cancel(root.request.id)
    }

    RowLayout {
        Layout.fillWidth: true
        Item {
            Layout.fillWidth: true
        }
        DialogButton {
            buttonText: "Cancel"
            onClicked: AskpassService.cancel(root.request.id)
        }
        DialogButton {
            buttonText: root.danger ? "Run anyway" : "Authenticate"
            onClicked: AskpassService.submit(root.request.id, passwordField.text)
        }
    }
}
