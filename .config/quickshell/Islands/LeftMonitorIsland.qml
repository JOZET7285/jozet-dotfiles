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
    width: leftRowLayoutMonitor.implicitWidth + 30
    height: Theme.height+5
    anchors {
        right: centerLand.left
        rightMargin: 15
    }
    color: Theme.bg_2
    radius: Theme.radius
    clip: true
    Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
    RowLayout {
        id: leftRowLayoutMonitor
        anchors.fill: parent
        anchors{
            margins: 1
            leftMargin: 15
            rightMargin: 15
        }
        spacing: 8
        // Memory
        BasePill {
            icon: "\uf233"
            text: sysManager.ramUsage + "%"
        }
        // Disk
        BasePill {
            icon: "\uf0a0" 
            text: sysManager.diskUsage + "%"
        }
    }
}