import Jozet.System 1.0
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
    SystemManager.ethernetInfo.status == "up"
        ? SystemManager.ethernetInfo
        : SystemManager.wifiInfo
    property bool loginError: false

    property url faceImage: {            
        let configHome = Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME"));
        return "file:/" + configHome + "/.local/share/jzt/assets/.face";
    }

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

        if (SystemManager.authenticateUser(SystemManager.currentUsername, passwordInput.text)) {
            loginError = false
            SystemManager.unlockSession()
        } else {
            passwordInput.text = ""
            loginError = true
        }
    }

    Image {
        id: screenshotImg
        anchors.fill: parent
        source: SystemManager.getWallpaperCachePath(modelData.name)
        visible: false
        cache: false
    }

    MultiEffect {
        anchors.fill: parent
        source: screenshotImg
        blurEnabled: true
        opacity: SystemManager.getSetting("display.lockscreen.blur")
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
        Item {
            id: centralDiv
            width: parent.width * 0.7
            height: parent.height * 0.7
            anchors.centerIn: parent
            clip: true

            Rectangle {
                anchors.fill: parent
                color: Theme.color_1_solid
                opacity: SystemManager.getSetting("display.lockscreen.opacity")
                radius: 75
            }

            Rectangle {
                id: leftDiv
                visible: SystemManager.getSetting("display.lockscreen.leftLand")
                width: parent.width * 0.2
                height: parent.height * 0.35
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                color: Theme.color_2
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
                            color: connection.type == "unknown" ? Theme.color_r : Theme.color_a_text
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
                                let devices = SystemManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if(connectedOnly.length === 0) return Theme.text_color
                                return Theme.color_g
                            }
                            font.pixelSize: 18
                        }
                        Text {
                            text: {
                                let devices = SystemManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if (connectedOnly.length === 0) {
                                    return "Disconnected";
                                }
                                return connectedOnly[Math.min(bluetoothBtn.currentDeviceIndex, connectedOnly.length - 1)].name;
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 15
                            color: {   
                                let devices = SystemManager.availableBluetoothDevices;
                                let connectedOnly = devices.filter(device => device.connected === true);
                                if(connectedOnly.length === 0) return Theme.color_a_text
                                return Theme.color_a_text
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
                                if(SystemManager.batteryStatus === "Charging") return Theme.color_g
                                else if (SystemManager.batteryStatus === "Full") return Theme.text_color
                                else{
                                    if (SystemManager.batteryCapacity > 90) return Theme.text_color
                                    if (SystemManager.batteryCapacity > 60) return Theme.color_y
                                    if (SystemManager.batteryCapacity > 30) return Theme.color_o
                                    return Theme.color_r
                                }
                            }
                            font.pixelSize: 18
                            text: {
                                if (SystemManager.batteryStatus === "Charging") return "\uf0e7"
                                else if (SystemManager.batteryStatus === "Full") return "\uf240"
                                else {
                                    if (SystemManager.batteryCapacity > 80) return "\uf240"
                                    if (SystemManager.batteryCapacity > 60) return "\uf241"
                                    if (SystemManager.batteryCapacity > 40) return "\uf242"
                                    if (SystemManager.batteryCapacity > 20) return "\uf243"
                                    return "\uf244"
                                }
                            }
                            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        }   
                        Text {
                            color: {
                                if(SystemManager.batteryStatus === "Charging") return Theme.color_g_text
                                else if (SystemManager.batteryStatus === "Full") return Theme.color_a_text
                                else{
                                    if (SystemManager.batteryCapacity > 90) return Theme.color_a_text
                                    if (SystemManager.batteryCapacity > 60) return Theme.color_y_text
                                    if (SystemManager.batteryCapacity > 30) return Theme.color_o_text
                                    return Theme.color_r
                                }
                            }
                            text: SystemManager.batteryCapacity + "%"
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
                visible: SystemManager.getSetting("display.lockscreen.rightLand")
                width: parent.width * 0.2
                height: parent.height * 0.35
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                color: Theme.color_2
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
                            text: (SystemManager.ramInfo.usagePercent || 0) + "%"
                            color: {
                                if (SystemManager.ramInfo.usagePercent < 25) return Theme.color_a_text
                                if (SystemManager.ramInfo.usagePercent < 50) return Theme.color_y_text
                                if (SystemManager.ramInfo.usagePercent < 75) return Theme.color_o_text
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
                            text: SystemManager.cpuUsage + "%"
                            color: {
                                if (SystemManager.cpuUsage < 25) return Theme.color_a_text
                                if (SystemManager.cpuUsage < 50) return Theme.color_y_text
                                if (SystemManager.cpuUsage < 75) return Theme.color_o_text
                                return Theme.color_r_text
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
                            text: SystemManager.maxTemp + "°C"
                            color: {
                                if (SystemManager.maxTemp < 75) return Theme.color_a_text
                                if (SystemManager.maxTemp < 95) return Theme.color_o_text
                                return Theme.color_r_text
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
                    color: Theme.text_color
                    font.pixelSize: 65
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: currentDate
                    color: Theme.text_color_secondary
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15
                Rectangle {
                    color: Theme.color_3
                    radius: 10
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 220
                    ColumnLayout {
                        anchors.centerIn: parent
                        Item {
                            width: 150 
                            height: 150 
                            Image {
                                id: artImage
                                anchors.fill: parent
                                source: faceImage
                                fillMode: Image.PreserveAspectCrop
                                visible: false
                            }
                            MultiEffect {
                                anchors.fill: parent
                                source: artImage
                                maskEnabled: true
                                maskSource: artMask
                            }
                            Item {
                                id: artMask
                                width: parent.width
                                height: parent.height
                                visible: false
                                layer.enabled: true
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: Theme.color_1_solid
                                }
                            }
                        }

                        Text {
                            text: SystemManager.currentUsername
                            color: Theme.text_color
                            font.pixelSize: 30
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                TextField {
                    id: passwordInput
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    horizontalAlignment: TextInput.AlignHCenter
                    color: Theme.text_color
                    Layout.preferredWidth: 250
                    Layout.alignment: Qt.AlignHCenter
                    focus: true
                    background: Rectangle {
                        color: Theme.color_3
                        radius: 10
                    }
                    onAccepted: tryLogin()
                }
                Text {
                    text: "Incorrect P1assword"
                    color: Theme.color_r_text
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
                        color: Theme.text_color
                        horizontalAlignment: Text.AlignHCenter
                    }
                    background: Rectangle {
                        color: Theme.color_4
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
            color: Theme.color_1_solid
            x: -width
        }

        Rectangle {
            id: rightDoor
            width: parent.width / 2
            height: parent.height
            color: Theme.color_1_solid
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
