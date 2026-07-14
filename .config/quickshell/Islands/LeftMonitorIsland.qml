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
    property var popups: [diskPopup]//, ramPopup]
    property var activePopup: {
        for (var i = 0; i < popups.length; i++) {
            var p = popups[i]
            if (p && (p.open || p.animating)) return p
        } 
        return null
    }
    y: 5
    width: leftRowLayoutMonitor.implicitWidth + 20
    height: 38 * scaleFactor
    
    Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    
    anchors {
        right: centerLand.left
        rightMargin: marginScaled
    }
    color: Theme.color_1
    radius: Theme.radius
    clip: true
    
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
            text: sysManager.ramUsage + "%"
        }
        BasePillSimple {
            id: diskUsagePill
            icon: "\uf0a0" 
            text: sysManager.diskUsage + "%"
            onClicked: diskPopup.open = !diskPopup.open
        }
    }
}