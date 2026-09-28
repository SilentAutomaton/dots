pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Listening sockets grouped by the process that owns them. Root is needed for
// the owners of root sockets, so ss runs through a sudoers rule for these exact
// arguments; the rule also keeps sudo from logging every poll.
Singleton {
    id: root

    // Exposure ranks: bound to loopback, to one interface or address, to all of them.
    readonly property int local: 0
    readonly property int iface: 1
    readonly property int any: 2

    // A port must stay open, or stay gone, this many polls in a row to count.
    readonly property int settlePolls: 2
    readonly property int recentMs: 10 * 60 * 1000

    property var groups: [] // [{ name, exposure, ports: [{ port, proto, exposure, change }] }]
    property var counts: [0, 0, 0]
    property bool available: true
    property int ephemeralLow: 32768
    property int ephemeralHigh: 60999

    property bool baselineTaken: false
    property var tracked: ({}) // key -> { entry, known, present, missing }
    property var recent: ({}) // key -> { change: "opened" | "closed", at, entry }
    property string noticeId: ""

    function exposureOf(host) {
        if (/^(127\.|::1$|::ffff:127\.)/.test(host) || host.endsWith("%lo"))
            return root.local;
        if (["*", "0.0.0.0", "::"].includes(host))
            return root.any;
        return root.iface;
    }

    function listeners(text) {
        const entries = {};
        for (const line of text.split("\n")) {
            const fields = line.trim().split(/\s+/);
            if (fields.length < 5)
                continue;
            const proto = fields[0];
            const address = fields[4];
            const colon = address.lastIndexOf(":");
            const host = address.slice(0, colon).replace(/^\[|\]$/g, "").replace(/\]%/, "%");
            const port = Number(address.slice(colon + 1));
            if (/^(22[4-9]|23\d)\.|^ff0/.test(host))
                continue;
            // UDP on an ephemeral port is a client (DNS, WebRTC, VPN), not a service.
            if (proto === "udp" && port >= root.ephemeralLow && port <= root.ephemeralHigh)
                continue;
            const name = line.match(/users:\(\("([^"]+)"/)?.[1] ?? "?";
            const key = `${name}|${port}/${proto}`;
            const exposure = Math.max(root.exposureOf(host), entries[key]?.exposure ?? 0);
            entries[key] = { name: name, port: port, proto: proto, exposure: exposure };
        }
        return entries;
    }

    // Loopback ports are left out: wine and WebKit open random ones all the time.
    function track(entries) {
        const now = Date.now();
        const opened = [];
        const closed = [];
        for (const [key, entry] of Object.entries(entries)) {
            if (entry.exposure === root.local)
                continue;
            const state = root.tracked[key] ?? { known: !root.baselineTaken, present: 0 };
            state.entry = entry;
            state.present++;
            state.missing = 0;
            if (!state.known && state.present >= root.settlePolls) {
                state.known = true;
                opened.push(entry);
                root.recent[key] = { change: "opened", at: now, entry: entry };
            }
            root.tracked[key] = state;
        }
        for (const [key, state] of Object.entries(root.tracked)) {
            if (key in entries && entries[key].exposure !== root.local)
                continue;
            state.present = 0;
            state.missing = (state.missing ?? 0) + 1;
            if (!state.known) {
                delete root.tracked[key];
            } else if (state.missing >= root.settlePolls) {
                closed.push(state.entry);
                root.recent[key] = { change: "closed", at: now, entry: state.entry };
                delete root.tracked[key];
            }
        }
        for (const [key, item] of Object.entries(root.recent)) {
            if (now - item.at > root.recentMs)
                delete root.recent[key];
        }
        root.baselineTaken = true;
        root.notice(opened, closed);
    }

    function notice(opened, closed) {
        const lines = opened.map(entry => `+ ${entry.name} ${entry.port}/${entry.proto}`)
            .concat(closed.map(entry => `− ${entry.name} ${entry.port}/${entry.proto}`));
        if (lines.length === 0 || noticeProc.running)
            return;
        const body = lines.length > 6 ? lines.slice(0, 6).join("\n") + `\n… ${lines.length - 6} more` : lines.join("\n");
        const replace = root.noticeId ? ["-r", root.noticeId] : [];
        noticeProc.command = ["notify-send", "-u", "low", "-e", "-t", "4000", "-a", "Ports", "-p", ...replace, "Ports", body];
        noticeProc.running = true;
    }

    function regroup(entries) {
        const shown = Object.entries(entries).map(([key, entry]) => Object.assign({}, entry, { change: root.recent[key]?.change === "opened" ? "opened" : "" }));
        for (const [key, item] of Object.entries(root.recent)) {
            if (item.change === "closed" && !(key in entries))
                shown.push(Object.assign({}, item.entry, { change: "closed" }));
        }

        const byName = {};
        const counts = [0, 0, 0];
        for (const entry of shown) {
            byName[entry.name] = byName[entry.name] ?? [];
            byName[entry.name].push(entry);
            if (entry.change !== "closed")
                counts[entry.exposure]++;
        }
        const groups = Object.entries(byName).map(([name, ports]) => ({
            name: name,
            exposure: Math.max(...ports.map(port => port.exposure)),
            ports: ports.sort((a, b) => a.port - b.port)
        }));
        groups.sort((a, b) => b.exposure - a.exposure || a.name.localeCompare(b.name));
        root.groups = groups;
        root.counts = counts;
    }

    function update(text) {
        // A failed ss prints nothing; that must not read as every port closing.
        if (text.trim() === "")
            return;
        const entries = root.listeners(text);
        root.track(entries);
        root.regroup(entries);
    }

    Process {
        running: true
        command: ["cat", "/proc/sys/net/ipv4/ip_local_port_range"]
        stdout: StdioCollector {
            onStreamFinished: {
                const range = text.trim().split(/\s+/).map(Number);
                root.ephemeralLow = range[0];
                root.ephemeralHigh = range[1];
            }
        }
    }

    Process {
        id: ssProc
        command: ["sudo", "-n", "ss", "-tulpnH"]
        stdout: StdioCollector {
            onStreamFinished: root.update(text)
        }
        onExited: exitCode => root.available = exitCode === 0
    }

    Process {
        id: noticeProc
        stdout: StdioCollector {
            onStreamFinished: root.noticeId = text.trim()
        }
    }

    Timer {
        running: true
        interval: 10000
        repeat: true
        triggeredOnStart: true
        onTriggered: ssProc.running = true
    }
}
