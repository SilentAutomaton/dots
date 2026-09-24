import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.panels.sidebarRight.calendar
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1
    clip: true
    implicitHeight: collapsed ? collapsedRow.implicitHeight : 350
    property bool collapsed: Persistent.states.sidebar.bottomGroup.collapsed

    Behavior on implicitHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }

    RowLayout {
        id: collapsedRow
        visible: root.collapsed
        spacing: 15

        CalendarHeaderButton {
            Layout.margins: 10
            Layout.rightMargin: 0
            forceCircle: true
            downAction: () => Persistent.states.sidebar.bottomGroup.collapsed = false
            contentItem: MaterialSymbol {
                text: "keyboard_arrow_up"
                iconSize: Appearance.font.pixelSize.larger
                horizontalAlignment: Text.AlignHCenter
                color: Appearance.colors.colOnLayer1
            }
        }

        StyledText {
            Layout.margins: 10
            Layout.leftMargin: 0
            text: DateTime.collapsedCalendarFormat
            font.pixelSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
        }
    }

    Item {
        visible: !root.collapsed
        anchors.fill: parent

        CalendarHeaderButton {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 10
            forceCircle: true
            downAction: () => Persistent.states.sidebar.bottomGroup.collapsed = true
            contentItem: MaterialSymbol {
                text: "keyboard_arrow_down"
                iconSize: Appearance.font.pixelSize.larger
                horizontalAlignment: Text.AlignHCenter
                color: Appearance.colors.colOnLayer1
            }
        }

        CalendarWidget {
            anchors.fill: parent
            anchors.leftMargin: 56
        }
    }
}
