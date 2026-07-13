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
    readonly property var marginScaled: 10 * scaleFactor
    y: 5
    width: leftRowLayoutMonitor.implicitWidth + 20
    height: 38 * scaleFactor
    anchors {
        right: centerLand.left
        rightMargin: marginScaled
    }
    color: Theme.color_1
    radius: Theme.radius
    clip: true
    Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
    RowLayout {
        id: leftRowLayoutMonitor
        anchors.fill: parent 
        anchors{
            margins: 1
            leftMargin: marginScaled
            rightMargin: marginScaled
        }
        spacing: 5 * scaleFactor

        BasePillSimple {
            icon: "\uf233"
            text: sysManager.ramUsage + "%"
        }
        BasePillSimple {
            icon: "\uf0a0" 
            text: sysManager.diskUsage + "%"
        }
    }
}