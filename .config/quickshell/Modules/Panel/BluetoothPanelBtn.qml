import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Components"
import "../../Popups"

Rectangle {
    id: bluetoothBtn
    implicitWidth: bluetoothPopup.open ? parent.width : contentbtRow.implicitWidth+20
    implicitHeight: (Theme.height - 5) * scaleFactor
    color: "transparent"
    
    property int currentDeviceIndex: 0

    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
    
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: bluetoothPopup.open = !bluetoothPopup.open
    }
    
    Connections {
        target: sysManager
        function onBluetoothChanged() {
            bluetoothBtn.currentDeviceIndex = 0
            deviceRotationTimer.restart()
        }
    }
    
    Timer {
        id: deviceRotationTimer
        interval: 120000 // 2 minutos
        repeat: true
        running: true
        onTriggered: {
            let connectedDevices = sysManager.availableBluetoothDevices.filter(d => d.connected);
            if (connectedDevices.length > 1) {
                bluetoothBtn.currentDeviceIndex = (bluetoothBtn.currentDeviceIndex + 1) % connectedDevices.length;
            }
        }
    }
    Row {
        id: contentbtRow
        anchors.centerIn: parent
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
    
}