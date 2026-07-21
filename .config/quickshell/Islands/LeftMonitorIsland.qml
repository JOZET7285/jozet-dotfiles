import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Components/Pills"
import "../Popups"
import "../Process"
import Jozet.System 1.0

Rectangle {
    y: 5
    
    readonly property var marginScaled: 10 * scaleFactor
    
    width: leftRowLayoutMonitor.implicitWidth + 20
    height: 38 * scaleFactor
    color: Theme.color_1_solid
    radius: Theme.radius
    clip: true
    
    anchors {
        right: centerLand.left
        rightMargin: marginScaled
    }

    Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    
    RowLayout {
        id: leftRowLayoutMonitor
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
            id: ramUsagePill
            icon: "\uf233"
            text: (sysManager.ramInfo.usagePercent.toFixed(1) || 0) + "%"
            color_text: {
                if (sysManager.ramInfo.usagePercent < 25) return Theme.color_b
                if (sysManager.ramInfo.usagePercent < 50) return Theme.color_y
                if (sysManager.ramInfo.usagePercent < 75) return Theme.color_o
                return Theme.color_r
            }
            onClicked: ramPopup.open = !ramPopup.open
        }
        BasePillSimple {
            id: diskUsagePill
            icon: "\uf0a0" 
            text: sysManager.diskUsage.toFixed(1) + "%"
            color_text: {
                if (sysManager.diskUsage < 25) return Theme.color_b
                if (sysManager.diskUsage < 50) return Theme.color_y
                if (sysManager.diskUsage < 75) return Theme.color_o
                return Theme.color_r
            }
            onClicked: diskPopup.open = !diskPopup.open
        }
    }
}