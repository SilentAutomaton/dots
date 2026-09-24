import QtQuick
import QtQuick.Layouts

ColumnLayout {
    readonly property bool matched: children.some(child => child.matched === true)
    spacing: 12
}
