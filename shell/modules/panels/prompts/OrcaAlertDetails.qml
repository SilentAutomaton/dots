import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    // Keeps the last alert while the window closes, so bindings never see null.
    property var alert: OrcaAlerts.details
    Binding on alert {
        when: OrcaAlerts.details !== null
        value: OrcaAlerts.details
        restoreMode: Binding.RestoreNone
    }

    function close() {
        OrcaAlerts.detailsId = null;
    }

    PromptDialog {
        anchors.fill: parent
        dialogWidth: 640
        onDismiss: root.close()

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            AppIcon {
                visible: source !== ""
                source: root.alert.appIcon
                implicitSize: 40
            }
            MaterialSymbol {
                visible: root.alert.appIcon === ""
                text: "warning"
                iconSize: 32
                color: root.alert.urgency === "critical" ? Appearance.colors.colError : Appearance.colors.colSecondary
            }
            WindowDialogTitle {
                Layout.fillWidth: true
                text: root.alert.summary || root.alert.appName
            }
            RippleButton {
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                onClicked: Quickshell.clipboardText = root.alert.body
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "content_copy"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer3
                }
            }
        }

        PromptDetailRow {
            label: "Warning"
            value: root.alert.body
        }
        PromptDetailRow {
            label: "Application"
            value: root.alert.appName
        }
        PromptDetailRow {
            label: "Time"
            value: Qt.formatDateTime(new Date(root.alert.time), "HH:mm:ss")
        }

        WindowDialogButtonRow {
            Item {
                Layout.fillWidth: true
            }
            Repeater {
                model: root.alert.buttons ?? []
                delegate: DialogButton {
                    required property var modelData
                    buttonText: modelData.label
                    onClicked: OrcaAlerts.answer(root.alert.id, modelData.index)
                }
            }
            DialogButton {
                visible: !(root.alert.buttons ?? []).length
                buttonText: "Dismiss"
                onClicked: OrcaAlerts.dismiss(root.alert.id)
            }
            DialogButton {
                buttonText: "Close"
                onClicked: root.close()
            }
        }
    }
}
