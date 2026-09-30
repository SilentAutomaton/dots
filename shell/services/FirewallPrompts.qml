pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// OpenSnitch connection prompts, relayed by ~/.local/bin/snitch-prompt.
// Each prompt carries the choices its card shows, so a global shortcut
// answers with whatever the card currently says.
Singleton {
    id: root

    property list<var> prompts: []
    property var detailsId: null
    readonly property var details: prompts.find(p => p.id === detailsId) ?? null
    readonly property bool connected: link.item?.connected ?? false

    readonly property list<var> actions: [
        { "displayName": "Allow", "icon": "check", "value": "allow" },
        { "displayName": "Deny", "icon": "block", "value": "deny" },
        { "displayName": "Reject", "icon": "close", "value": "reject" },
    ]
    readonly property list<var> durations: [
        { "displayName": "Once", "value": "once" },
        { "displayName": "30 seconds", "value": "30s" },
        { "displayName": "5 minutes", "value": "5m" },
        { "displayName": "15 minutes", "value": "15m" },
        { "displayName": "30 minutes", "value": "30m" },
        { "displayName": "1 hour", "value": "1h" },
        { "displayName": "12 hours", "value": "12h" },
        { "displayName": "Until restart", "value": "until restart" },
        { "displayName": "Always", "value": "always" },
    ]
    readonly property list<var> extras: [
        { "displayName": "Destination IP", "value": "dstIp" },
        { "displayName": "Destination port", "value": "dstPort" },
        { "displayName": "User ID", "value": "uid" },
        { "displayName": "Executable checksum", "value": "checksum" },
    ]

    function baseName(path) {
        return path.split("/").pop();
    }

    function appEntry(prompt) {
        return prompt.path ? DesktopEntries.heuristicLookup(baseName(prompt.path)) : null;
    }

    function appName(prompt) {
        if (prompt.steamAppId)
            return `Steam game ${prompt.steamAppId}`;
        return appEntry(prompt)?.name ?? (baseName(prompt.path) || "Unknown process");
    }

    function destination(prompt) {
        const port = prompt.dstPort ? `:${prompt.dstPort}` : "";
        return `${prompt.dstHost || prompt.dstIp}${port} (${prompt.protocol})`;
    }

    function choiceSummary(prompt) {
        const duration = durations.find(d => d.value === prompt.duration)?.displayName ?? prompt.duration;
        const target = prompt.targets.find(t => t.key === prompt.target)?.label ?? prompt.target;
        return `${duration}, ${target}`;
    }

    function send(message) {
        if (root.connected)
            link.item.write(JSON.stringify(message) + "\n");
    }

    function sendConfig() {
        send({ "type": "config", "hold": Config.options.firewallPrompts.hold });
    }

    function withChoices(prompt) {
        const options = Config.options.firewallPrompts;
        const target = prompt.targets.some(t => t.key === options.defaultTarget) ? options.defaultTarget : "path";
        return Object.assign(prompt, { "duration": options.defaultDuration, "target": target, "extras": [] });
    }

    function choose(id, key, value) {
        prompts = prompts.map(p => p.id === id ? Object.assign({}, p, { [key]: value }) : p);
    }

    function toggleExtra(id, extra) {
        const prompt = prompts.find(p => p.id === id);
        choose(id, "extras", prompt.extras.includes(extra) ? prompt.extras.filter(e => e !== extra) : [...prompt.extras, extra]);
    }

    function answer(id, action) {
        const prompt = prompts.find(p => p.id === id);
        if (!prompt)
            return;
        send({
            "type": "answer", "id": id, "action": action,
            "duration": prompt.duration, "target": prompt.target, "extras": prompt.extras
        });
    }

    function dismiss(id) {
        send({ "type": "dismiss", "id": id });
    }

    function handle(message) {
        if (message.type === "ask" && !prompts.some(p => p.id === message.id)) {
            prompts = [...prompts, withChoices(message)];
        } else if (message.type === "resolved") {
            prompts = prompts.filter(p => p.id !== message.id);
            if (detailsId === message.id)
                detailsId = null;
        }
    }

    // A Socket whose connect was refused never tries again, so every retry
    // builds a new one. snitch-prompt may start after the shell or restart
    // under it.
    LazyLoader {
        id: link
        active: true
        component: Socket {
            path: `${Quickshell.env("XDG_RUNTIME_DIR")}/snitch-prompt.sock`
            connected: true
            parser: SplitParser {
                onRead: line => root.handle(JSON.parse(line))
            }
            onConnectedChanged: {
                if (connected) {
                    root.sendConfig();
                } else {
                    root.prompts = [];
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

    Connections {
        target: Config.options.firewallPrompts
        function onHoldChanged() {
            root.sendConfig();
        }
    }

    GlobalShortcut {
        name: "firewallAllow"
        description: "Allows the oldest firewall prompt with the choices on its card"
        onPressed: if (root.prompts.length > 0) root.answer(root.prompts[0].id, "allow")
    }
    GlobalShortcut {
        name: "firewallDeny"
        description: "Denies the oldest firewall prompt with the choices on its card"
        onPressed: if (root.prompts.length > 0) root.answer(root.prompts[0].id, "deny")
    }
    GlobalShortcut {
        name: "firewallDetails"
        description: "Opens or closes the full window of the oldest firewall prompt"
        onPressed: root.detailsId = root.detailsId === null && root.prompts.length > 0 ? root.prompts[0].id : null
    }
}
