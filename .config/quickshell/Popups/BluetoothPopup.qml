import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components/"
import "../Modules/Bluetooth"

BasePrincipalPopup {
    id: bluetoothPopup
    popupName: "bluetooth"

    property string connectingAddress: ""

    popupContent: Component {
        Item {
            width: parent.width
            height: Math.min(
                Math.max(150, calculateHeight()),
                550
            )
            
            function calculateHeight() {
                let h = 30;
                h += 25;
                h += 10;
                
                let connectedCount = SystemManager.availableBluetoothDevices.filter(d => d.connected).length;
                h += connectedCount > 0 ? (connectedCount * 50 + (connectedCount - 1) * 8) : 25;
                
                h += 10;
                h += 1; 
                h += 10;
                h += 25;
                h += 10;
                
                let availableCount = Math.min(SystemManager.availableBluetoothDevices.filter(d => !d.connected).length, 9);
                let gridRows = Math.ceil(availableCount / 3);
                h += gridRows > 0 ? (gridRows * 50 + (gridRows - 1) * 10) : 0;
                
                return h;
            }
            Behavior on height { 
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } 
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                clip: true

                Label {
                    text: "Connected"
                    color: Theme.text_color
                    font.bold: true
                    font.pointSize: 11
                }

                ColumnLayout {
                    id: connectedRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    spacing: 8
                    clip: true

                    readonly property var connectedList: SystemManager.availableBluetoothDevices.filter(d => d.connected)
                    readonly property int count: connectedList.length
                    property real contentHeight: count > 0 ? (count * 50 + (count - 1) * 8) : 25

                    Text {
                        visible: connectedRow.count === 0
                        text: "No connected devices"
                        color: Theme.text_color_secondary
                        font.italic: true
                        Layout.fillWidth: true
                    }

                    Repeater {
                        id: connectedDevices
                        model: connectedRow.connectedList

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.color_2
                            radius: 8
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: Theme.color_b_text
                                }

                                Column {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.name || "Device"
                                        color: Theme.text_color
                                        font.bold: true
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        text: modelData.address
                                        color: Theme.text_color_secondary
                                        font.pixelSize: 9
                                    }
                                }

                                Button {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    text: "✕"
                                    contentItem: Text {
                                        text: parent.text
                                        color: Theme.text_color
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.hovered ? Theme.color_r_solid : Theme.color_3_solid
                                        radius: 4
                                        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                    }
                                    onClicked: {
                                        SystemManager.disconnectBluetooth(modelData.address)
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.color_3_solid
                }

                Label {
                    text: "Availables"
                    color: Theme.text_color
                    font.bold: true
                    font.pointSize: 11
                }

                AvailableList { id: availableList}
            }
        }
    }
}