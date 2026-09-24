pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property string query: ""
    readonly property bool active: query.trim().length > 0

    function matches(texts) {
        const needle = query.trim().toLowerCase();
        return texts.some(text => text.toLowerCase().includes(needle));
    }
}
