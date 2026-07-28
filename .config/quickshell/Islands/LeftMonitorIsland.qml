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
    height: 30 * scaleFactor
    color: Theme.color_1_solid
    radius: Theme.radius
    clip: true
    
    anchors {
        right: centerLand.left
        rightMargin: marginScaled
    }

    Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 250 } }
    
    RowLayout {
        id: leftRowLayoutMonitor
        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: marginScaled
            rightMargin: marginScaled
        }
        height: 30 * scaleFactor
        spacing: 5 * scaleFactor

        BasePillSimple {
            id: ramUsagePill
            icon: "\uf233"
            text: (SystemManager.ramInfo.usagePercent || 0) + "%"
            color_text: {
                if (SystemManager.ramInfo.usagePercent < 25) return Theme.color_a_text
                if (SystemManager.ramInfo.usagePercent < 50) return Theme.color_y_text
                if (SystemManager.ramInfo.usagePercent < 75) return Theme.color_o_text
                return Theme.color_r_text
            }
            onClicked: ramPopup.open = !ramPopup.open
        }
        BasePillSimple {
            id: diskUsagePill
            icon: "\uf0a0" 
            text: SystemManager.diskUsage.toFixed(1) + "%"
            color_text: {
                if (SystemManager.diskUsage < 25) return Theme.color_a_text
                if (SystemManager.diskUsage < 50) return Theme.color_y_text
                if (SystemManager.diskUsage < 75) return Theme.color_o_text
                return Theme.color_r_text
            }
            onClicked: diskPopup.open = !diskPopup.open
        }
    }
}