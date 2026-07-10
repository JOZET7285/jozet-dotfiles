import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Effects
import "../Components"
import "../Popups"
import "../Process"
import "../Modules/Network"
import "../Modules/Panel"
import Jozet.System 1.0

Rectangle {
    id: rightIsland
    y: 5

    property var popups: [networkPopup, bluetoothPopup, powerPopup, volumePopup]
    property var connection:
    sysManager.ethernetInfo.status !== "down"
        ? sysManager.ethernetInfo
        : sysManager.wifiInfo

    property var activePopup: {
        for (var i = 0; i < popups.length; i++) {
            var p = popups[i]
            if (p && (p.open || p.animating)) return p
        }
        return null
    }

    width: activePopup ? Math.max(
        activePopup === networkPopup ? 400 :
        activePopup === powerPopup ? 200 :
        activePopup === bluetoothPopup ? 400 :
        activePopup === volumePopup ? 420 : 0
        ) : rightRowLayoutId.implicitWidth + 30
    height: activePopup ? Theme.height + activePopup.height : Theme.height 

    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    anchors { 
        right: parent.right 
        rightMargin: 15 
    }
    color: Theme.bg_2
    radius: Theme.radius
    clip: true
    RowLayout {
        id: rightRowLayoutId
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 15
            rightMargin: 15
        }
        height: Theme.height
        spacing: 8

        NetworkPanelBtn {
            visible: activePopup == null || activePopup == networkPopup
        }
        BluetoothPanelBtn {
            visible: activePopup == null || activePopup == bluetoothPopup
        }
        Rectangle {
            id: volumeBtn
            implicitWidth: volumePopup.open ? parent.width : contentRow.implicitWidth+20
            implicitHeight: Theme.height - 6
            color: (volumePopup.selected ? Theme.bg_3 : (volumeBtnArea.containsMouse ? Theme.bg_2 : "transparent"))
            radius: volumePopup.selected ? Theme.radius : 8
            visible: activePopup == null || activePopup == volumePopup
            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
            Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            
            MouseArea {
                id: volumeBtnArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: volumePopup.open = !volumePopup.open
            }
            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: {
                        if(volumePopup.playbackDevice && volumePopup.playbackDevice.isMuted) return "\uf026"
                        if(volumePopup.playbackDevice && volumePopup.playbackDevice.volume > 70.0) return "\uf028"
                        if(volumePopup.playbackDevice && volumePopup.playbackDevice.volume > 30.0) return "\uf027"
                        return "\uf026"
                    }
                    color: "white"
                    font.pixelSize: 13
                }
                Text {
                    text: volumePopup.playbackDevice ? volumePopup.playbackDevice.volume + "%" : "0%"
                    color: "white"
                    font.pixelSize: 13
                }
            }
        }
        BasePill {
            icon: {
                if (mainProcesses.batteryPercent === "charging") return "\uf0e7"
                if (mainProcesses.batteryPercent > 80) return "\uf240"
                if (mainProcesses.batteryPercent > 60) return "\uf241"
                if (mainProcesses.batteryPercent > 40) return "\uf242"
                if (mainProcesses.batteryPercent > 20) return "\uf243"
                return "\uf244"
            }
            visible: activePopup == null
        }
        Rectangle {
            id: powerBtn
            implicitWidth: powerPopup.open ? parent.width : contentbtRow.implicitWidth+20
            implicitHeight: Theme.height - 6
            color: (powerPopup.selected ? Theme.bg_3 : (powerBtnArea.containsMouse ? Theme.bg_2 : "transparent"))
            radius: powerBtn.selected ? Theme.radius : 8
            visible: activePopup == null || activePopup == powerPopup
            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
            Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            
            MouseArea {
                id: powerBtnArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: powerPopup.open = !powerPopup.open
            }
            Row {
                id: contentbtRow
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: "\uf011"
                    color: "white"
                    font.pixelSize: 13
                }
            }
        }
    }
    
    NetworkPopup { 
        id: networkPopup 
        anchors.top: rightRowLayoutId.bottom
        connection: rightIsland.connection
    }
    PowerPopup {
        id: powerPopup
        anchors.top: rightRowLayoutId.bottom
    }
    BluetoothPopup { 
        id: bluetoothPopup
        anchors.top: rightRowLayoutId.bottom 
        anchors.right: parent.right 
    }
    VolumePopup {
        id: volumePopup
        anchors.top: rightRowLayoutId.bottom
        anchors.right: parent.right
    }
}