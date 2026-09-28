pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// sudo password prompts from shell-askpass. The helper listens on a private
// socket and hands its path over IPC; the context and the answer travel over
// that socket, so the password never reaches an argument or a log.
Singleton {
    id: root

    property list<var> requests: []
    property var detailsId: null
    readonly property var details: requests.find(r => r.id === detailsId) ?? null
    property int nextId: 1

    function submit(id, password) {
        finish(id, { "password": password });
    }

    function cancel(id) {
        finish(id, { "cancel": true });
    }

    function finish(id, reply) {
        const request = requests.find(r => r.id === id);
        if (!request)
            return;
        request.socket.write(JSON.stringify(reply) + "\n");
        request.socket.flush();
        remove(id);
    }

    // The socket destroys itself once the helper hangs up.
    function remove(id) {
        requests = requests.filter(r => r.id !== id);
        if (detailsId === id)
            detailsId = null;
    }

    function received(socket, context) {
        requests = [...requests, Object.assign({ "id": root.nextId++, "socket": socket }, context)];
    }

    Component {
        id: requestSocket
        Socket {
            id: socket
            connected: true
            parser: SplitParser {
                onRead: line => root.received(socket, JSON.parse(line))
            }
            // sudo gave up or the helper was killed
            onConnectedChanged: {
                if (connected)
                    return;
                const request = root.requests.find(r => r.socket === socket);
                if (request)
                    root.remove(request.id);
                socket.destroy();
            }
        }
    }

    IpcHandler {
        target: "askpass"

        function request(path: string): void {
            requestSocket.createObject(root, { "path": path });
        }
    }
}
