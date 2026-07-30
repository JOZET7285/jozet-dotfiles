import Jozet.System 1.0
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
    property bool compactMode: SystemManager.getSetting("theme.panel.compact") === true

    Connections {
        target: SystemManager
        function onRiceSettingsChanged() {
            compactMode = SystemManager.getSetting("theme.panel.compact") === true
        }
    }

    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
    
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: bluetoothPopup.open = !bluetoothPopup.open
    }
    
    Connections {
        target: SystemManager
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
            let connectedDevices = SystemManager.availableBluetoothDevices.filter(d => d.connected);
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
                let devices = SystemManager.availableBluetoothDevices;
                let connectedOnly = devices.filter(device => device.connected === true);
                if(connectedOnly.length === 0) return Theme.text_color
                return Theme.color_g_text
            }
            font.pixelSize: 14
        }
        Text {
            visible: compactMode ? area.containsMouse : true
            text: {
                let devices = SystemManager.availableBluetoothDevices;
                let connectedOnly = devices.filter(device => device.connected === true);
                if (connectedOnly.length === 0) {
                    return "Disconnected";
                }
                return connectedOnly[Math.min(bluetoothBtn.currentDeviceIndex, connectedOnly.length - 1)].name;
            }
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 12
            color: {   
                let devices = SystemManager.availableBluetoothDevices;
                let connectedOnly = devices.filter(device => device.connected === true);
                if(connectedOnly.length === 0) return Theme.color_a_text
                return Theme.color_g_text
            }
            font.bold: true
        }
    }
    
}