import qs.modules.common
import QtQuick
import QtQuick.Layouts

// A centred dialog over a scrim that grows with its content. WindowDialog
// fixes its height when it opens, and prompt details wrap only after that.
Item {
    id: root
    property real dialogWidth: 640
    default property alias content: contentColumn.data

    signal dismiss

    focus: true
    Keys.onEscapePressed: root.dismiss()

    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.colScrim
        MouseArea {
            anchors.fill: parent
            onPressed: root.dismiss()
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(root.dialogWidth, root.width - 40)
        height: Math.min(contentColumn.implicitHeight + 2 * radius, root.height - 40)
        radius: Appearance.rounding.large
        color: Appearance.m3colors.m3surfaceContainerHigh
        clip: true

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: contentColumn
            anchors {
                fill: parent
                margins: parent.radius
            }
            spacing: 12
        }
    }
}
