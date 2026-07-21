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

        Text {
            visible: sysManager.usbDevices.length === 0
            text: "No hay dispositivos USB conectados"
            font.pixelSize: 12; color: Theme.color_b
        }

        Repeater {
            model: sysManager.usbDevices
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Theme.color_2
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: modelData.name || modelData.devicePath.split('/').pop(); font.pixelSize: 12; font.bold: true; color: Theme.text_color }
                        Text { text: modelData.size + (modelData.mounted ? " — " + modelData.mountPoint : " — No montado"); font.pixelSize: 11; color: Theme.color_b }
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 26
                        radius: 6
                        color: modelData.mounted ? Theme.color_r : Theme.color_g
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.mounted) sysManager.unmountUsbDevice(modelData.devicePath)
                                else sysManager.mountUsbDevice(modelData.devicePath)
                            }
                        }
                        Text { anchors.centerIn: parent; text: modelData.mounted ? "Desmontar" : "Montar"; font.pixelSize: 11; font.bold: true; color: "white" }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}