pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Whether traffic to the internet leaves through a tunnel the agents are
// allowed to use. The tunnel list is the one OpenSnitch enforces, read from
// the vpn-only allow rule, so the indicator and the firewall never disagree.
Singleton {
    id: root

    readonly property string allowRule: "/etc/opensnitchd/rules/000-vpnonly-allow-claude.json"
    // An AmneziaWG peer shakes hands every two minutes while traffic flows.
    readonly property int staleAfter: 180

    property list<string> tunnels: []
    property string routeIface: ""
    readonly property bool throughTunnel: tunnels.includes(routeIface)
    property int handshakeAge: -1 // seconds; -1 while unknown
    readonly property bool stale: throughTunnel && (handshakeAge < 0 || handshakeAge > staleAfter)

    property string exitIp: ""
    property string exitCountry: ""
    property bool exitLoading: exitProc.running

    function refreshExit() {
        if (!exitProc.running) exitProc.running = true;
    }

    onRouteIfaceChanged: {
        root.exitIp = "";
        root.exitCountry = "";
        handshakeProc.running = true;
    }

    Process {
        id: tunnelsProc
        running: true
        command: ["jq", "-r", '.operator.list[] | select(.operand == "iface.out") | .data', root.allowRule]
        stdout: StdioCollector {
            onStreamFinished: {
                const names = text.trim().replace(/^\^\(/, "").replace(/\)\$$/, "").split("|");
                root.tunnels = names.filter(name => name.length > 0 && name !== "lo");
            }
        }
    }

    Process {
        id: routeProc
        running: true
        command: ["ip", "route", "get", "1.1.1.1"]
        stdout: StdioCollector {
            onStreamFinished: root.routeIface = text.match(/\bdev (\S+)/)?.[1] ?? ""
        }
    }

    // Every route or link change asks the kernel again; nothing polls.
    Process {
        running: true
        command: ["ip", "monitor", "route", "link"]
        stdout: SplitParser {
            onRead: routeProc.running = true
        }
    }

    Process {
        id: handshakeProc
        command: ["sudo", "-n", "awg", "show", "all", "latest-handshakes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n").find(line => line.startsWith(`${root.routeIface}\t`));
                const stamp = Number(line?.split("\t")[2] ?? 0);
                root.handshakeAge = stamp > 0 ? Math.round(Date.now() / 1000 - stamp) : -1;
            }
        }
    }

    Timer {
        running: root.throughTunnel
        interval: 30000
        repeat: true
        triggeredOnStart: true
        onTriggered: handshakeProc.running = true
    }

    // Runs only on a click. The country comes from the local GeoIP database, so
    // only the IP lookup leaves the machine, through the tunnel being checked.
    Process {
        id: exitProc
        command: ["bash", "-c", 'ip=$(curl -s --max-time 5 ifconfig.me) && echo "$ip" && geoiplookup "$ip" | sed "s/^[^:]*: //"']
        stdout: StdioCollector {
            onStreamFinished: {
                const [ip, country] = text.trim().split("\n");
                root.exitIp = ip ?? "";
                root.exitCountry = country ?? "";
            }
        }
    }
}
