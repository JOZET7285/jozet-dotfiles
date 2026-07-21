import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: bluetoothSection
    ColumnLayout {
        spacing: 12
        Text { text: "Bluetooth"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        RowLayout {
            spacing: 10
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 28
                radius: 6
                color: Theme.color_g
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sysManager.scanBluetooth(true)
                }
                Text { anchors.centerIn: parent; text: "Escanear"; font.pixelSize: 11; font.bold: true; color: "white" }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: sysManager.availableBluetoothDevices
            delegate: Rectangle {
                width: ListView.view.width
                height: 36
                color: "transparent"
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Text { text: modelData.name; font.pixelSize: 12; color: Theme.text_color; Layout.fillWidth: true }
                    Text {
                        text: modelData.connected ? "Conectado" : "Desconectado"
                        font.pixelSize: 11
                        color: modelData.connected ? Theme.color_g : Theme.color_b
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}