import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Effects
import "Components"

PanelWindow {
    id: lockWindow

     anchors { 
        top: true 
        bottom: true 
        left: true 
        right: true 
    }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "lockscreen"

    property var modelData
    screen: modelData

    property var connection:
    sysManager.ethernetInfo.status == "up"
        ? sysManager.ethernetInfo
        : sysManager.wifiInfo
    property bool loginError: false


    property string currentTime: Qt.formatDateTime(new Date(), "hh:mm")
    property string currentDate: Qt.formatDateTime(new Date(), "ddd, dd MMM")
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            currentTime = Qt.formatDateTime(new Date(), "hh:mm")
            currentDate = Qt.formatDateTime(new Date(), "ddd, dd MMM")
        }
    }

    function tryLogin() {
        if (passwordInput.text.length === 0) return

        if (sysManager.authenticateUser(sysManager.currentUsername, passwordInput.text)) {
            loginError = false
            sysManager.unlockSession()
        } else {
            passwordInput.text = ""
            loginError = true
        }
    }

    Image {
        id: screenshotImg
        anchors.fill: parent
        source: sysManager.getWallpaperCachePath(modelData.name)
        visible: false
        cache: false
    }

    MultiEffect {
        anchors.fill: parent
        source: screenshotImg
        blurEnabled: true
        blurMax: 100
        blur: 1.0
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
    }

    WlrLayershell.layer: WlrLayer.Overlay 
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: Qt.rgba(0, 0, 0, 0.5)
    Item {
        id: mainLockContent
        anchors.fill: parent
        opacity: 0
        Rectangle {
            id: centralDiv
            width: parent.width * 0.7
            height: parent.height * 0.7
            anchors.centerIn: parent
            color: "#1a1a1a"
            radius: 75
            clip: true

            Rectangle {
                id: leftDiv
                width: parent.width * 0.2
                height: parent.height * 0.35
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                color: "#2b2b2b"
                bottomRightRadius: 50
                topRightRadius: 50
                z: 10   

                ColumnLayout {
                    anchors.centerIn: parent
                    Row {
                        id: contentRow
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 8
                        Text{
                            text: (connection.type == "ethernet" ? "\uf0e8" : connection.type == "wifi" ? "\uf1eb" : "\uf127")
                            color: connection.type == "unknown" ? Theme.color_r : Theme.text_color
                            font.pixelSize: 18
                        }
                        Text{
                            text: connection.name !== "" ? connection.name : (connection.type == "ethernet" ? "Ethernet" : connection.type == "wifi" ? "Wi-Fi" : "No connection")
                            color: connection.type == "unknown" ? Theme.color_r : Theme.color_b
                            font.bold: true
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Row {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 8
                        Text {
                            text: "\uf293"
                            color: {   
                                let devices = sysManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if(connectedOnly.length === 0) return Theme.text_color
                                return Theme.color_g
                            }
                            font.pixelSize: 18
                        }
                        Text {
                            text: {
                                let devices = sysManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if (connectedOnly.length === 0) {
                                    return "Disconnected";
                                }
                                return connectedOnly[Math.min(bluetoothBtn.currentDeviceIndex, connectedOnly.length - 1)].name;
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 15
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
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
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
                            font.pixelSize: 18
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
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                            font.bold: true
                            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        }
                    }
                }
            }

            Rectangle {
                id: rightDiv
                width: parent.width * 0.2
                height: parent.height * 0.35
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                color: "#2b2b2b"
                topLeftRadius: 50
                bottomLeftRadius: 50
                z: 10 

                ColumnLayout {
                    anchors.centerIn: parent
                    Row {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 8
                        Text {
                            text: "\uf233" 
                            color: Theme.text_color
                            font.pixelSize: 18
                        }
                        Text { 
                            text: (sysManager.ramInfo.usagePercent || 0) + "%"
                            color: {
                                if (sysManager.ramInfo.usagePercent < 25) return Theme.color_b
                                if (sysManager.ramInfo.usagePercent < 50) return Theme.color_y
                                if (sysManager.ramInfo.usagePercent < 75) return Theme.color_o
                                return Theme.color_r
                            } 
                            font.bold: true
                            font.pixelSize: 15
                        }
                    }
                    Row {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 8
                        Text {
                            text: "\uf2db"
                            color: Theme.text_color
                            font.pixelSize: 18
                        }
                        Text { 
                            text: sysManager.cpuUsage + "%"
                            color: {
                                if (sysManager.cpuUsage < 25) return Theme.color_b
                                if (sysManager.cpuUsage < 50) return Theme.color_y
                                if (sysManager.cpuUsage < 75) return Theme.color_o
                                return Theme.color_r
                            } 
                            font.bold: true
                            font.pixelSize: 15
                        }
                    }
                    Row {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 8
                        Text {
                            text: "\uf2c9"
                            color: Theme.text_color
                            font.pixelSize: 18
                        }
                        Text {
                            text: sysManager.maxTemp + "°C"
                            color: {
                                if (sysManager.maxTemp < 75) return Theme.color_b
                                if (sysManager.maxTemp < 95) return Theme.color_o
                                return Theme.color_r
                            }
                            font.pixelSize: 15
                            font.bold: true
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
                    text: sysManager.currentUsername
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
                    focus: true
                    background: Rectangle {
                        color: "#2b2b2b"
                        radius: 10
                    }
                    onAccepted: tryLogin()
                }
                Text {
                    text: "Contraseña incorrecta"
                    color: Theme.color_r
                    font.pixelSize: 12
                    visible: loginError
                    Layout.alignment: Qt.AlignHCenter
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
                    onClicked: tryLogin()
                }
            }
        }
    }

    Item {
        id: animationOverlay
        anchors.fill: parent
        z: 999

        Rectangle {
            id: leftDoor
            width: parent.width / 2
            height: parent.height
            color: "#1a1a1a"
            x: -width
        }

        Rectangle {
            id: rightDoor
            width: parent.width / 2
            height: parent.height
            color: "#1a1a1a"
            x: parent.width
        }
    }

    SequentialAnimation {
        running: true
        
        ParallelAnimation {
            NumberAnimation {
                target: leftDoor
                property: "x"
                to: 0
                duration: 350
                easing.type: Easing.OutQuint
            }
            NumberAnimation {
                target: rightDoor
                property: "x"
                to: lockWindow.width / 2
                duration: 350
                easing.type: Easing.OutQuint
            }
        }
        PropertyAction { target: mainLockContent; property: "opacity"; value: 1 }
        
        PauseAnimation { duration: 200 }

        ParallelAnimation {
            NumberAnimation {
                target: leftDoor
                property: "x"
                to: -lockWindow.width / 2
                duration: 450
                easing.type: Easing.InOutCubic
            }
            NumberAnimation {
                target: rightDoor
                property: "x"
                to: lockWindow.width
                duration: 450
                easing.type: Easing.InOutCubic
            }
        }
        
        PropertyAction { target: animationOverlay; property: "visible"; value: false }
    }
}
