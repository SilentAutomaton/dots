import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

// A labelled text option. The config value changes when editing finishes,
// not on every keystroke, so a half-typed path never reaches the shell.
RowLayout {
    id: root
    property string text
    property string icon
    property string value
    property string placeholder
    signal accepted(string value)

    Layout.fillWidth: true
    Layout.leftMargin: 8
    Layout.rightMargin: 8
    spacing: 10

    OptionalMaterialSymbol {
        icon: root.icon
        iconSize: Appearance.font.pixelSize.larger
    }
    StyledText {
        text: root.text
        color: Appearance.colors.colOnSecondaryContainer
    }
    ToolbarTextField {
        Layout.fillWidth: true
        Layout.fillHeight: false
        implicitHeight: 34
        colBackground: Appearance.colors.colLayer2
        text: root.value
        placeholderText: root.placeholder
        onEditingFinished: root.accepted(text)
    }
}
