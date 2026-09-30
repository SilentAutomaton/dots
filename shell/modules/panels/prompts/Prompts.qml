import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell

// The full windows a prompt card opens: every field, whole commands.
Scope {
    FullscreenPolkitWindow {
        active: FirewallPrompts.details !== null
        contentComponent: Component {
            FirewallPromptDetails {}
        }
    }
    FullscreenPolkitWindow {
        active: AskpassService.details !== null
        contentComponent: Component {
            AskpassPromptDetails {}
        }
    }
    FullscreenPolkitWindow {
        active: OrcaAlerts.details !== null
        contentComponent: Component {
            OrcaAlertDetails {}
        }
    }
}
