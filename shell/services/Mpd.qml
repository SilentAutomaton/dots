pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

// MPD through mpc. The property names follow MprisPlayer, so the media panel
// can draw MPD with the same card it uses for MPRIS players.
Singleton {
    id: root

    property bool connected: false
    property bool isPlaying: false
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackAlbum: ""
    property string file: ""
    property string trackArtUrl: ""
    property real position: 0
    property real length: 0
    readonly property bool canSeek: true

    function togglePlaying() {
        Quickshell.execDetached(["mpc", "-q", "toggle"]);
    }
    function next() {
        Quickshell.execDetached(["mpc", "-q", "next"]);
    }
    function previous() {
        Quickshell.execDetached(["mpc", "-q", "prev"]);
    }
    function seek(seconds) {
        root.position = seconds;
        Quickshell.execDetached(["mpc", "-q", "seek", `${Math.round(seconds)}`]);
    }

    function secondsFor(time) {
        return time.split(":").reduce((total, part) => total * 60 + Number(part), 0);
    }

    function applyStatus(text) {
        const lines = text.split("\n");
        const stateIndex = lines.findIndex(line => /^\[(playing|paused)\]/.test(line));
        if (stateIndex < 1) {
            root.isPlaying = false;
            root.trackTitle = "";
            root.trackArtist = "";
            root.file = "";
            root.position = 0;
            root.length = 0;
            return;
        }
        const [artist, title, album, file] = lines[stateIndex - 1].split("\t");
        const state = lines[stateIndex];
        const times = state.match(/(\d+(?::\d+)+)\/(\d+(?::\d+)+)/);
        root.isPlaying = state.startsWith("[playing]");
        root.trackArtist = artist;
        root.trackTitle = title || FileUtils.fileNameForPath(file);
        root.trackAlbum = album;
        root.file = file;
        root.position = times ? root.secondsFor(times[1]) : 0;
        root.length = times ? root.secondsFor(times[2]) : 0;
    }

    onFileChanged: {
        root.trackArtUrl = "";
        if (root.file === "") return;
        coverProc.target = `${Directories.coverArt}/mpd-${Qt.md5(root.file)}.img`;
        coverProc.running = true;
    }

    Process {
        id: statusProc
        command: ["mpc", "-f", "%artist%\t%title%\t%album%\t%file%", "status"]
        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(text)
        }
        onExited: (exitCode, exitStatus) => root.connected = exitCode === 0
    }

    // Every player, mixer or options event reprints the status. When MPD goes
    // away the loop exits, the card hides, and the retry timer brings it back.
    Process {
        id: idleProc
        running: true
        command: ["mpc", "idleloop", "player", "mixer", "options"]
        stdout: SplitParser {
            onRead: statusProc.running = true
        }
        onStarted: statusProc.running = true
        onExited: {
            root.connected = false;
            retryTimer.start();
        }
    }

    Timer {
        id: retryTimer
        interval: 10000
        onTriggered: idleProc.running = true
    }

    Timer {
        running: root.isPlaying
        interval: 1000
        repeat: true
        onTriggered: root.position = Math.min(root.length, root.position + 1)
    }

    // Embedded pictures first, cover files next to the track second.
    Process {
        id: coverProc
        property string target
        command: ["bash", "-c", `[ -s "$1" ] || mpc readpicture "$2" > "$1" 2>/dev/null; [ -s "$1" ] || mpc albumart "$2" > "$1" 2>/dev/null; [ -s "$1" ]`, "_", target, root.file]
        onExited: (exitCode, exitStatus) => root.trackArtUrl = exitCode === 0 ? `file://${coverProc.target}` : ""
    }
}
