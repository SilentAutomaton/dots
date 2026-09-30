pragma Singleton
pragma ComponentBehavior: Bound

import qs.services
import QtQuick
import Quickshell
import Quickshell.Io

// OrcaSlicer alerts as prompt cards: no countdown, no silent mode, dismissed
// by hand. Desktop notifications are routed here from Notifications; modal
// dialogs come from ~/.local/bin/orca-watch over a unix socket, and a card
// button press presses the real button in the dialog.
Singleton {
    id: root

    property list<var> alerts: []
    property var detailsId: null
    readonly property var details: alerts.find(a => a.id === detailsId) ?? null
    property int nextId: 1

    // Every spelling seen from the AppImage and the packages: OrcaSlicer,
    // orca-slicer, com.softfever.orcaslicer
    function fromOrca(appName: string, desktopEntry: string): bool {
        return (appName ?? "").toLowerCase().includes("orca")
            || (desktopEntry ?? "").toLowerCase().includes("orca");
    }

    function add(appName: string, summary: string, body: string, image: string,
                 appIcon: string, urgency: string) {
        const guessed = AppSearch.guessIcon(appIcon || appName);
        const icon = (guessed === "image-missing" || guessed === "application-x-executable") ? "" : guessed;
        alerts = [...alerts, {
            "id": root.nextId++,
            "appName": appName,
            "summary": summary,
            "body": body,
            "image": image,
            "appIcon": icon,
            "urgency": urgency,
            "time": Date.now(),
        }];
    }

    function answer(id: int, index: int) {
        link.item?.write(JSON.stringify({ "type": "answer", "id": id, "index": index }) + "\n");
    }

    function dismiss(id: int) {
        const alert = alerts.find(a => a.id === id);
        if (alert?.buttons)
            link.item?.write(JSON.stringify({ "type": "dismiss", "id": id }) + "\n");
        alerts = alerts.filter(a => a.id !== id);
        if (detailsId === id)
            detailsId = null;
    }

    function handle(message) {
        if (message.type === "ask" && !alerts.some(a => a.id === message.id)) {
            alerts = [...alerts, {
                "id": message.id,
                "appName": "OrcaSlicer",
                "summary": message.title,
                "body": message.text,
                "image": "",
                "appIcon": ((guess) => (guess === "image-missing" || guess === "application-x-executable") ? "" : guess)(AppSearch.guessIcon("orca-slicer")),
                "urgency": "normal",
                "time": Date.now(),
                "buttons": message.buttons,
            }];
        } else if (message.type === "resolved") {
            alerts = alerts.filter(a => a.id !== message.id);
            if (detailsId === message.id)
                detailsId = null;
        }
    }

    // A Socket whose connect was refused never tries again, so every retry
    // builds a new one.
    LazyLoader {
        id: link
        active: true
        component: Socket {
            path: `${Quickshell.env("XDG_RUNTIME_DIR")}/orca-alerts.sock`
            connected: true
            parser: SplitParser {
                onRead: line => root.handle(JSON.parse(line))
            }
            onConnectedChanged: {
                if (!connected) {
                    root.alerts = root.alerts.filter(a => !a.buttons);
                    root.detailsId = null;
                }
            }
            onError: reconnectTimer.restart()
        }
    }

    Timer {
        id: reconnectTimer
        interval: 3000
        onTriggered: {
            link.active = false;
            link.active = true;
        }
    }
}
