import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Popups"
import "../Process"
import "../Modules/Network"
import "../Modules/Panel"
import Jozet.System 1.0

Rectangle {
    y: 5

    property var popups: [networkPopup /* bluetoothPopup, settingsPopup*/, powerPopup ]
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
        activePopup === powerPopup && 200
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
        
        BasePill {
            icon: "\uf293"
            text: ""
            visible: activePopup == null
        }
        BasePill {
            icon: {
                if(mainProcesses.volumePercent === "mute") return "\uf6a9"
                if(mainProcesses.volumePercent > 60) return "\uf028"
                if(mainProcesses.volumePercent > 30) return "\uf027"
                return "\uf026"
            }
            visible: activePopup == null
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
        BasePill {
            icon: "\uf011"
            onClicked: powerPopup.open = !powerPopup.open
            visible: activePopup == null || activePopup == powerPopup
        }
    }
    NetworkPopup { 
        id: networkPopup 
        anchors.top: rightRowLayoutId.bottom 
    }
    PowerPopup {
        id: powerPopup
        anchors.top: rightRowLayoutId.bottom
    }
    // BluetoothPopup { id: bluetoothPopup; anchors.top: rightRowLayoutId.bottom; anchors.right: parent.right }
}