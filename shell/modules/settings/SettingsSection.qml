import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

// One card of related options. While searching, the card stays visible when
// its title or any label inside it matches, so options keep their context.
Rectangle {
    id: root
    property string title
    property string icon
    default property alias contentData: content.data

    readonly property bool matched: !SettingsSearch.active || SettingsSearch.matches(labels())
    visible: matched
    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + 32
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1

    function labels() {
        const out = [root.title];
        const walk = item => {
            for (const child of item.children) {
                // Icon names are text too; they must not match a search.
                if (typeof child.text === "string" && child.text.length > 0 && child.iconSize === undefined) out.push(child.text);
                if (child.options) out.push(...child.options.map(option => option.displayName ?? ""));
                walk(child);
            }
        };
        walk(content);
        return out;
    }

    ColumnLayout {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 16
        }
        spacing: 10

        RowLayout {
            spacing: 8
            MaterialSymbol {
                text: root.icon
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colPrimary
            }
            StyledText {
                text: root.title
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer1
            }
        }

        ColumnLayout {
            id: content
            Layout.fillWidth: true
            spacing: 2
        }
    }
}
