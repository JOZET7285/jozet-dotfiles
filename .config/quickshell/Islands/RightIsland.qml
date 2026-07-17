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

    property int marginScaled: 15 * scaleFactor
    property var popups: [networkPopup, bluetoothPopup, energyPopup, volumePopup, powerPopup]
    property var connection:
    sysManager.ethernetInfo.status !== "down"
        ? sysManager.ethernetInfo
        : sysManager.wifiInfo

    property bool networkPopupOpen: networkPopup.open

    property var activePopup: {
        for (var i = 0; i < popups.length; i++) {
            var p = popups[i]
            if (p && (p.open || p.animating)) return p
        }
        return null
    }

    width: activePopup ? Math.max(
        activePopup === networkPopup ? 400 :
        activePopup === powerPopup ? 200  :
        activePopup === bluetoothPopup ? 400 :
        activePopup === energyPopup ? 420 :
        activePopup === volumePopup ? 420 : 0
        ) * (scaleFactor + 0.1)  : rightRowLayoutId.implicitWidth + 30
    height: activePopup ? 38 * scaleFactor + activePopup.height : 38 * scaleFactor 

    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    anchors { 
        right: parent.right 
    }
    color: Theme.color_1_solid
    bottomLeftRadius: 38
    clip: true

    RowLayout {
        id: rightRowLayoutId
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: marginScaled
            rightMargin: marginScaled
        }
        height: 38 * scaleFactor
        spacing: 8 * scaleFactor

        NetworkPanelBtn {
            visible: activePopup == null || activePopup == networkPopup
        }
        BluetoothPanelBtn {
            visible: activePopup == null || activePopup == bluetoothPopup
        }
        Rectangle {
            id: volumeBtn
            implicitWidth: volumePopup.open ? parent.width : contentvolRow.implicitWidth+20
            implicitHeight: (Theme.height - 5) * scaleFactor
            color: "transparent"
            radius: 8
            visible: activePopup == null || activePopup == volumePopup
            Behavior on color { ColorAnimation { duration: 350; easing.type: Easing.InOutQuad } }
            Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            
            MouseArea {
                id: volumeBtnArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: volumePopup.open = !volumePopup.open
            }
            Row {
                id: contentvolRow
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: {
                        if(volumePopup.playbackDevice && volumePopup.playbackDevice.isMuted) return "\uf026"
                        if(volumePopup.playbackDevice && volumePopup.playbackDevice.volume > 70.0) return "\uf028"
                        if(volumePopup.playbackDevice && volumePopup.playbackDevice.volume > 30.0) return "\uf027"
                        return "\uf026"
                    }
                    color: Theme.text_color
                    font.pixelSize: 14
                }
                Text {
                    visible: scaleFactor > 0.8 ? true : volumeBtnArea.containsMouse 
                    text: volumePopup.playbackDevice ? volumePopup.playbackDevice.volume + "%" : "0%"
                    color: Theme.color_b
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        Rectangle {
            id: batteryBtn
            implicitWidth: energyPopup.open ? parent.width : contentbatRow.implicitWidth+20
            implicitHeight: (Theme.height - 6) * scaleFactor
            color: "transparent"
            visible: activePopup == null || activePopup == energyPopup
            
            Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Row {
                id: contentbatRow
                anchors.centerIn: parent
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
            MouseArea {
                id: batteryBtnArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: energyPopup.open = !energyPopup.open
            }
        }
        Rectangle {
            id: powerBtn
            implicitWidth: powerPopup.open ? parent.width : contentpowerRow.implicitWidth+20
            implicitHeight: (Theme.height - 5) * scaleFactor
            color: "transparent"
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
                id: contentpowerRow
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: "\uf011"
                    color: Theme.color_o
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
    EnergyPopup {
        id: energyPopup
        anchors.top: rightRowLayoutId.bottom
        anchors.right: parent.right
    }
    PowerPopup {
        id: powerPopup
        anchors.top: rightRowLayoutId.bottom
    }
}