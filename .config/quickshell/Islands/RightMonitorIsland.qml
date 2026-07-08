import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Popups"
import "../Process"
import "../Islands"
import Jozet.System 1.0

Rectangle {
    y: 5
    width: rightRowLayoutMonitor.implicitWidth + 10
    height: Theme.height
    anchors {
        left: centerLand.right
        leftMargin: 15
    }
    radius: Theme.radius
    color: Theme.bg_2
    clip: true
    Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
    RowLayout {
        id: rightRowLayoutMonitor
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8
        // cpu
        BasePill {
            icon: "\uf2db"
            text: sysManager.cpuUsage + "%"
        }
        // temp
        BasePill {
            icon: "\uf2c9"
            text: sysManager.cpuTemp + "°C"
        }
    }
}