pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

// The notification history that the overlay keeps. The overlay owns the
// notification server and the popups; the shell reads its file and sends every
// change back over the overlay's IPC.
Singleton {
    id: root

    property list<var> list: []
    property bool silent: false
    readonly property int unread: list.filter(notif => notif.unread).length
    readonly property list<var> popupList: []
    readonly property var groupsByAppName: groupsForList(list)
    readonly property var popupGroupsByAppName: ({})
    readonly property list<string> appNameList: Object.keys(groupsByAppName).sort((a, b) => groupsByAppName[b].time - groupsByAppName[a].time)
    readonly property list<string> popupAppNameList: []

    function groupsForList(list) {
        const groups = {};
        list.forEach(notif => {
            if (!groups[notif.appName])
                groups[notif.appName] = {
                    "appName": notif.appName,
                    "appIcon": notif.appIcon,
                    "notifications": [],
                    "time": 0,
                };
            groups[notif.appName].notifications.push(notif);
            groups[notif.appName].time = Math.max(groups[notif.appName].time, notif.time);
        });
        return groups;
    }

    function call(name, ...args) {
        Quickshell.execDetached(["qs", "-c", "overlay", "ipc", "call", "notifications", name, ...args.map(String)]);
    }

    onSilentChanged: {
        if (silent !== saved.silent)
            call("setSilent", silent);
    }

    function discardNotification(id) {
        call("dismiss", id);
    }

    function discardAllNotifications() {
        call("clear");
    }

    function attemptInvokeAction(id, identifier) {
        call("invoke", id, identifier);
    }

    function timeoutAll() {
        call("hidePopups");
    }

    function setSidebarOpen(open) {
        call("setSidebarOpen", open);
    }

    // Popups live in the overlay.
    function cancelTimeout(id) {}
    function timeoutNotification(id) {}

    property var saved: ({ "silent": false, "notifications": [] })
    onSavedChanged: {
        list = saved.notifications;
        silent = saved.silent;
    }

    FileView {
        id: file
        path: `${StandardPaths.writableLocation(StandardPaths.GenericCacheLocation)}/quickshell/notifications/overlay.json`.replace("file://", "")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.saved = JSON.parse(file.text())
    }
}
