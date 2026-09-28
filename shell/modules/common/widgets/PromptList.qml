import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell
import QtQuick.Layouts

// Pending firewall and sudo prompts. They skip the notification server: they
// never time out and silent mode does not hide them.
ColumnLayout {
    id: root
    spacing: 6
    visible: AskpassService.requests.length + FirewallPrompts.prompts.length > 0

    Repeater {
        // ScriptModel keeps a card, and the password typed into it, while others come and go
        model: ScriptModel {
            values: AskpassService.requests
        }
        delegate: AskpassPromptCard {
            required property var modelData
            Layout.fillWidth: true
            request: modelData
        }
    }
    Repeater {
        model: ScriptModel {
            values: FirewallPrompts.prompts
        }
        delegate: FirewallPromptCard {
            required property var modelData
            Layout.fillWidth: true
            prompt: modelData
        }
    }
}
