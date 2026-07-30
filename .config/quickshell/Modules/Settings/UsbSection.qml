import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: usbSection
    ColumnLayout {
        spacing: 12
        Text { text: "USB"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Text { text: "Devices"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 15; Layout.rightMargin: 15
            color: Theme.color_2; radius: 5
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 8; spacing: 6
                Text {
                    visible: SystemManager.usbDevices.length === 0
                    text: "No hay dispositivos USB conectados"
                    font.pixelSize: 12; color: Theme.color_a_text
                }
                Repeater {
                    model: SystemManager.usbDevices
                    delegate: Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 50
                        color: Theme.color_1_solid; radius: 8

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 12
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                Text { text: modelData.name || modelData.devicePath.split('/').pop(); font.pixelSize: 12; font.bold: true; color: Theme.text_color }
                                Text { text: modelData.size + (modelData.mounted ? " — " + modelData.mountPoint : " — No montado"); font.pixelSize: 11; color: Theme.color_a_text }
                            }
                            Rectangle {
                                Layout.preferredWidth: 80; Layout.preferredHeight: 26; radius: 6
                                color: modelData.mounted ? Theme.color_r : Theme.color_g
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.mounted) SystemManager.unmountUsbDevice(modelData.devicePath)
                                        else SystemManager.mountUsbDevice(modelData.devicePath)
                                    }
                                }
                                Text { anchors.centerIn: parent; text: modelData.mounted ? "Desmontar" : "Montar"; font.pixelSize: 11; font.bold: true; color: "white" }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}