import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Popups"
import "../Process"
import Jozet.System 1.0

Rectangle {
    y: 5

    property var popups: [networkPopup /* bluetoothPopup, settingsPopup, powerPopup */]

    property var activePopup: {
        for (var i = 0; i < popups.length; i++) {
            var p = popups[i]
            if (p && (p.open || p.animating)) return p
        }
        return null
    }

    width: activePopup ? Math.max(rightRowLayoutId.implicitWidth + 80, activePopup.width) : rightRowLayoutId.implicitWidth + 30
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
        BasePill {
            icon: {
                if (mainProcesses.netStatus === "Ethernet") return "\uf0e8"
                if (mainProcesses.netStatus === "Wi-Fi") return "\uf1eb"
                return "\uf127"
            } 
            onClicked: networkPopup.open = !networkPopup.open
        }
        BasePill {
            icon: "\uf293"
            text: ""
        }
        BasePill {
            icon: "\uf185"
        }
        BasePill {
            icon: {
                if(mainProcesses.volumePercent === "mute") return "\uf6a9"
                if(mainProcesses.volumePercent > 60) return "\uf028"
                if(mainProcesses.volumePercent > 30) return "\uf027"
                return "\uf026"
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
        }
        BasePill {
            icon: "\uf013"
        }
        BasePill {
            icon: "\uf011"
        }
    }
    NetworkPopup { 
        id: networkPopup 
        anchors.top: rightRowLayoutId.bottom 
        anchors.left: parent.left 
    }
    // BluetoothPopup { id: bluetoothPopup; anchors.top: rightRowLayoutId.bottom; anchors.right: parent.right }
}