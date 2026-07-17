import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/Pills"
import "../Components"
import "../Popups"
import "../Process"
import "../Islands"
import Jozet.System 1.0

Rectangle {
    y: 5
    
    readonly property var marginScaled: 10 * scaleFactor

    width: rightRowLayoutMonitor.implicitWidth + 20
    height: 38 * scaleFactor
    radius: Theme.radius
    color: Theme.color_1_solid
    clip: true
    
    anchors {
        left: centerLand.right
        leftMargin: marginScaled
    }

    Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    RowLayout {
        id: rightRowLayoutMonitor
        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: marginScaled
            rightMargin: marginScaled
        }
        height: 38 * scaleFactor
        spacing: 5 * scaleFactor

        BasePillSimple {
            icon: "\uf2db"
            text: sysManager.cpuUsage + "%"
            onClicked: cpuPopup.open = !cpuPopup.open
            color_text: {
                if (sysManager.cpuUsage < 25) return Theme.color_b
                if (sysManager.cpuUsage < 50) return Theme.color_y
                if (sysManager.cpuUsage < 75) return Theme.color_o
                return Theme.color_r
            }
        }
        BasePillSimple {
            icon: "\uf2c9"
            text: sysManager.maxTemp + "°C"
            color_text: {
                if (sysManager.maxTemp < 75) return Theme.color_b
                if (sysManager.maxTemp < 95) return Theme.color_o
                return Theme.color_r
            }
            onClicked: tempPopup.open = !tempPopup.open
        }
    }
}