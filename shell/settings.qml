//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.settings

ApplicationWindow {
    id: root
    property real contentPadding: 8
    property int currentPage: 0
    readonly property var pages: [
        { "name": "Appearance", "icon": "palette", "component": appearancePage },
        { "name": "Bar", "icon": "toolbar", "component": barPage },
        { "name": "Panels", "icon": "side_navigation", "component": panelsPage },
        { "name": "System", "icon": "settings", "component": systemPage },
        { "name": "Lock", "icon": "lock", "component": lockPage }
    ]

    Component { id: appearancePage; AppearancePage {} }
    Component { id: barPage; BarPage {} }
    Component { id: panelsPage; PanelsPage {} }
    Component { id: systemPage; SystemPage {} }
    Component { id: lockPage; LockPage {} }

    visible: true
    onClosing: Qt.quit()
    title: "Shell Settings"
    minimumWidth: 760
    minimumHeight: 500
    width: 1000
    height: 720
    color: Appearance.m3colors.m3background

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme();
        // The app writes one option at a time, so writes need no batching delay.
        Config.readWriteDelay = 0;
    }

    Shortcut {
        sequence: StandardKey.Find
        onActivated: searchField.forceActiveFocus()
    }
    Shortcut {
        sequences: ["Ctrl+PgDown", "Ctrl+Tab"]
        onActivated: root.currentPage = (root.currentPage + 1) % root.pages.length
    }
    Shortcut {
        sequences: ["Ctrl+PgUp", "Ctrl+Shift+Tab"]
        onActivated: root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: root.contentPadding
        }

        Item {
            visible: Config.options.windows.showTitlebar
            Layout.fillWidth: true
            implicitHeight: Math.max(titleText.implicitHeight, closeButton.implicitHeight)

            StyledText {
                id: titleText
                anchors {
                    left: Config.options.windows.centerTitle ? undefined : parent.left
                    horizontalCenter: Config.options.windows.centerTitle ? parent.horizontalCenter : undefined
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
                color: Appearance.colors.colOnLayer0
                text: "Settings"
                font.family: Appearance.font.family.title
                font.pixelSize: Appearance.font.pixelSize.title
            }
            RippleButton {
                id: closeButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                buttonRadius: Appearance.rounding.full
                implicitWidth: 35
                implicitHeight: 35
                onClicked: root.close()
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "close"
                    iconSize: 20
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.contentPadding

            ColumnLayout {
                id: rail
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.preferredWidth: 200
                Layout.maximumWidth: 200
                Layout.margins: 5
                spacing: 12

                ToolbarTextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    implicitHeight: 40
                    placeholderText: "Search  (Ctrl+F)"
                    font.pixelSize: Appearance.font.pixelSize.small
                    onTextChanged: SettingsSearch.query = text
                    Keys.onEscapePressed: text = ""
                }

                NavigationRailTabArray {
                    Layout.fillWidth: true
                    currentIndex: SettingsSearch.active ? -1 : root.currentPage
                    expanded: true
                    Repeater {
                        model: root.pages
                        NavigationRailButton {
                            required property int index
                            required property var modelData
                            toggled: !SettingsSearch.active && root.currentPage === index
                            onPressed: {
                                searchField.text = "";
                                root.currentPage = index;
                            }
                            expanded: true
                            buttonIcon: modelData.icon
                            buttonText: modelData.name
                            showToggledHighlight: false
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                RippleButtonWithIcon {
                    Layout.fillWidth: true
                    materialIcon: "data_object"
                    mainText: "Open config file"
                    onClicked: Qt.openUrlExternally(`file://${Directories.shellConfigPath}`)
                    StyledToolTip {
                        text: "Only options changed here are stored. Defaults live in Config.qml"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.m3colors.m3surfaceContainerLow
                radius: Appearance.rounding.windowRounding - root.contentPadding

                StyledFlickable {
                    id: flickable
                    anchors.fill: parent
                    clip: true
                    contentHeight: pageColumn.implicitHeight + 80

                    ColumnLayout {
                        id: pageColumn
                        width: Math.min(flickable.width - 48, 720)
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 24
                        spacing: 24

                        Repeater {
                            id: pageRepeater
                            model: root.pages
                            ColumnLayout {
                                id: pageBlock
                                required property int index
                                required property var modelData
                                visible: SettingsSearch.active ? (pageLoader.item?.matched ?? false) : root.currentPage === index
                                Layout.fillWidth: true
                                spacing: 12

                                StyledText {
                                    text: pageBlock.modelData.name
                                    font.family: Appearance.font.family.title
                                    font.pixelSize: Appearance.font.pixelSize.huge
                                    color: Appearance.colors.colOnLayer0
                                }
                                Loader {
                                    id: pageLoader
                                    Layout.fillWidth: true
                                    active: Config.ready
                                    sourceComponent: pageBlock.modelData.component
                                }
                            }
                        }

                        StyledText {
                            visible: SettingsSearch.active && !root.pages.some((_, i) => pageRepeater.itemAt(i)?.visible)
                            Layout.fillWidth: true
                            Layout.topMargin: 60
                            horizontalAlignment: Text.AlignHCenter
                            text: `Nothing matches "${SettingsSearch.query}". Try a shorter word.`
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onCurrentPageChanged() {
            flickable.contentY = 0;
        }
    }
}
