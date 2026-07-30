import Jozet.System 1.0
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

        Text { text: "Devices"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 15; Layout.rightMargin: 15
            color: Theme.color_2; radius: 5
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 8; spacing: 8
                Rectangle {
                    Layout.preferredHeight: 28; Layout.preferredWidth: 100
                    radius: 6; color: Theme.color_g
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: SystemManager.scanBluetooth(true)
                    }
                    Text { anchors.centerIn: parent; text: "Scan"; font.pixelSize: 11; font.bold: true; color: "white" }
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    model: SystemManager.availableBluetoothDevices
                    delegate: Rectangle {
                        width: ListView.view.width; height: 36; color: "transparent"; radius: 6
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 10
                            Text { text: modelData.name; font.pixelSize: 12; color: Theme.text_color; Layout.fillWidth: true }
                            Text {
                                text: modelData.connected ? "Connected" : "Disconnected"
                                font.pixelSize: 11
                                font.bold: true
                                color: modelData.connected ? Theme.color_g : Theme.color_a_text
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}