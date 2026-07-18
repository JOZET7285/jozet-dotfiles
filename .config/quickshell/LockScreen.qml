import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Components"

PanelWindow {
    id: lockWindow

    property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Overlay 
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: Qt.rgba(0, 0, 0, 0.5)
    Item {
        anchors.fill: parent
        Rectangle {
            id: centralDiv
            width: parent.width * 0.7
            height: parent.height * 0.7
            anchors.centerIn: parent
            color: "#1a1a1a"
            radius: 100

            Rectangle {
                id: leftDiv
                width: parent.width * 0.25
                height: parent.height * 0.35
                anchors.verticalCenter: parent.verticalCenter
                x: -width * 0.3 
                color: "#2b2b2b"
                radius: 100
                z: -1

                ColumnLayout {
                    anchors.centerIn: parent
                    Row {
                        id: contentRow
                        Layout.alignment: Qt.AlignHCenter || Qt.AlignVCenter
                        spacing: 8
                        Text{
                            text: (connection.type == "ethernet" ? "\uf0e8" : connection.type == "wifi" ? "\uf1eb" : "\uf127")
                            color: connection.type == "unknown" ? Theme.color_r : Theme.text_color
                            font.pixelSize: 14
                        }
                        Text{
                            visible: scaleFactor > 0.8 ? true : area.containsMouse
                            text: connection.name !== "" ? connection.name : (connection.type == "ethernet" ? "Ethernet" : connection.type == "wifi" ? "Wi-Fi" : "No connection")
                            color: connection.type == "unknown" ? Theme.color_r : Theme.color_b
                            font.bold: true
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Row {
                        Layout.alignment: Qt.AlignHCenter || Qt.AlignVCenter
                        spacing: 8
                        Text {
                            text: "\uf293"
                            color: {   
                                let devices = sysManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if(connectedOnly.length === 0) return Theme.text_color
                                return Theme.color_g
                            }
                            font.pixelSize: 14
                        }
                        Text {
                            visible: scaleFactor > 0.8 ? true : area.containsMouse
                            text: {
                                let devices = sysManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if (connectedOnly.length === 0) {
                                    return "Disconnected";
                                }
                                return connectedOnly[Math.min(bluetoothBtn.currentDeviceIndex, connectedOnly.length - 1)].name;
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 12
                            color: {   
                                let devices = sysManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if(connectedOnly.length === 0) return Theme.color_b
                                return Theme.color_g
                            }
                            font.bold: true
                        }
                    }
                    Row {
                        Layout.alignment: Qt.AlignHCenter || Qt.AlignVCenter
                        spacing: 8
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            color: {
                                if(sysManager.batteryStatus === "Charging") return Theme.color_g
                                else if (sysManager.batteryStatus === "Full") return Theme.text_color
                                else{
                                    if (sysManager.batteryCapacity > 90) return Theme.text_color
                                    if (sysManager.batteryCapacity > 60) return Theme.color_y
                                    if (sysManager.batteryCapacity > 30) return Theme.color_o
                                    return Theme.color_r
                                }
                            }
                            font.pixelSize: 14
                            text: {
                                if (sysManager.batteryStatus === "Charging") return "\uf0e7"
                                else if (sysManager.batteryStatus === "Full") return "\uf240"
                                else {
                                    if (sysManager.batteryCapacity > 80) return "\uf240"
                                    if (sysManager.batteryCapacity > 60) return "\uf241"
                                    if (sysManager.batteryCapacity > 40) return "\uf242"
                                    if (sysManager.batteryCapacity > 20) return "\uf243"
                                    return "\uf244"
                                }
                            }
                            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        }   
                        Text {
                            visible: scaleFactor > 0.8 ? true : batteryBtnArea.containsMouse
                            color: {
                                if(sysManager.batteryStatus === "Charging") return Theme.color_g
                                else if (sysManager.batteryStatus === "Full") return Theme.color_b
                                else{
                                    if (sysManager.batteryCapacity > 90) return Theme.color_b
                                    if (sysManager.batteryCapacity > 60) return Theme.color_y
                                    if (sysManager.batteryCapacity > 30) return Theme.color_o
                                    return Theme.color_r
                                }
                            }
                            text: sysManager.batteryCapacity + "%"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                            font.bold: true
                            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        }
                    }
                }
            }

            Rectangle {
                id: rightDiv
                width: parent.width * 0.25
                height: parent.height * 0.35
                anchors.verticalCenter: parent.verticalCenter
                x: parent.width - (width * 0.7)
                color: "#2b2b2b"
                radius: 100
                z: -1 

                ColumnLayout {
                    anchors.centerIn: parent
                    Row {
                        Layout.alignment: Qt.AlignHCenter || Qt.AlignVCenter
                        spacing: 8
                        Text {
                            text: "\uf233" 
                        }
                        Text { 
                            text: (sysManager.ramInfo.usagePercent || 0) + "%"
                            color: {
                                if (sysManager.ramInfo.usagePercent < 25) return Theme.color_b
                                if (sysManager.ramInfo.usagePercent < 50) return Theme.color_y
                                if (sysManager.ramInfo.usagePercent < 75) return Theme.color_o
                                return Theme.color_r
                            } 
                        }
                    }
                    Row {
                        Text {
                            text: "\uf2db"
                        }
                        Text { 
                            text: sysManager.cpuUsage + "%"
                            color: {
                                if (sysManager.cpuUsage < 25) return Theme.color_b
                                if (sysManager.cpuUsage < 50) return Theme.color_y
                                if (sysManager.cpuUsage < 75) return Theme.color_o
                                return Theme.color_r
                            } 
                        }
                    }
                    Row {
                        Text {
                            text: "\uf2c9"
                        }
                        Text {
                            text: sysManager.maxTemp + "°C"
                            color: {
                                if (sysManager.maxTemp < 75) return Theme.color_b
                                if (sysManager.maxTemp < 95) return Theme.color_o
                                return Theme.color_r
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                Text {
                    text: currentTime
                    color: "white"
                    font.pixelSize: 65
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: currentDate
                    color: "#6f6f6f"
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: "username"
                    color: "white"
                    font.pixelSize: 30
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: passwordInput
                    placeholderText: "Contraseña"
                    echoMode: TextInput.Password
                    horizontalAlignment: TextInput.AlignHCenter
                    color: "white"
                    Layout.preferredWidth: 250
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle {
                        color: "#2b2b2b"
                        radius: 10
                    }
                }

                Button {
                    text: "Login"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 120
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                    background: Rectangle {
                        color: "#2b2b2b"
                        radius: 10
                    }
                }
            }
        }
    }
}