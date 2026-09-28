pragma Singleton
pragma ComponentBehavior: Bound

import qs
import QtQuick
import Quickshell
import Quickshell.Io

// Listening sockets grouped by the process that owns them. Root is needed for
// the owners of root sockets, so ss runs through a sudoers rule for these exact
// arguments.
Singleton {
    id: root

    // Exposure ranks: bound to loopback, to one interface or address, to all of them.
    readonly property int local: 0
    readonly property int iface: 1
    readonly property int any: 2

    property var groups: [] // [{ name, exposure, ports: [{ port, proto, exposure }] }]
    property var counts: [0, 0, 0]
    property bool available: true
    property int ephemeralLow: 32768
    property int ephemeralHigh: 60999

    function exposureOf(host) {
        if (/^(127\.|::1$|::ffff:127\.)/.test(host) || host.endsWith("%lo"))
            return root.local;
        if (["*", "0.0.0.0", "::"].includes(host))
            return root.any;
        return root.iface;
    }

    function parse(text) {
        const byName = {};
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
            const exposure = root.exposureOf(host);
            byName[name] = byName[name] ?? { name: name, ports: {} };
            const group = byName[name];
            const key = `${port}/${proto}`;
            group.ports[key] = { port: port, proto: proto, exposure: Math.max(exposure, group.ports[key]?.exposure ?? 0) };
        }

        const counts = [0, 0, 0];
        const groups = Object.values(byName).map(group => {
            const ports = Object.values(group.ports).sort((a, b) => a.port - b.port);
            ports.forEach(port => counts[port.exposure]++);
            return { name: group.name, exposure: Math.max(...ports.map(port => port.exposure)), ports: ports };
        });
        groups.sort((a, b) => b.exposure - a.exposure || a.name.localeCompare(b.name));
        root.groups = groups;
        root.counts = counts;
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
            onStreamFinished: root.parse(text)
        }
        onExited: exitCode => root.available = exitCode === 0
    }

    Timer {
        running: GlobalStates.sidebarRightOpen
        interval: 5000
        repeat: true
        triggeredOnStart: true
        onTriggered: ssProc.running = true
    }
}
