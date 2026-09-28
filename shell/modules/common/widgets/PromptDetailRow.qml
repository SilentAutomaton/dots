import qs.modules.common
import QtQuick
import QtQuick.Layouts

// One labelled value in a prompt's full window, whole and selectable.
RowLayout {
    id: root
    property string label
    property string value
    property bool monospace: false

    Layout.fillWidth: true
    visible: value !== ""
    spacing: 12

    StyledText {
        Layout.preferredWidth: 110
        Layout.alignment: Qt.AlignTop
        text: root.label
        font.pixelSize: Appearance.font.pixelSize.small
        color: Appearance.colors.colSubtext
    }
    TextEdit {
        Layout.fillWidth: true
        text: root.value
        readOnly: true
        selectByMouse: true
        wrapMode: TextEdit.WrapAnywhere
        color: Appearance.colors.colOnLayer3
        selectionColor: Appearance.colors.colSecondaryContainer
        selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
        font.pixelSize: Appearance.font.pixelSize.small
        font.family: root.monospace ? Appearance.font.family.monospace : Appearance.font.family.main
    }
}
