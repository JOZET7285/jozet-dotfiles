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
    width: (appLauncher.open || appLauncher.animating)
        ? Math.max(leftRowLayoutId.implicitWidth + 80, appLauncher.width) 
        : leftRowLayoutId.implicitWidth + 30
    height: (appLauncher.open || appLauncher.animating)
            ? Theme.height + appLauncher.height
            : Theme.height
    anchors {
        left: parent.left
        leftMargin: 15
    }
    color: Theme.color_1
    radius: Theme.radius
    clip: true
    property alias appLauncherOpen: appLauncher.open
    
    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    RowLayout {
        id: leftRowLayoutId
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
            icon: "\uf46d" 
            text: "Apps"
            selected: appLauncher.open
            onClicked: appLauncher.open = !appLauncher.open
        }
        Workspaces {
            Layout.leftMargin: 15
            Layout.alignment: Qt.AlignVCenter
        }
    }

    AppLauncher {
        id: appLauncher
        anchors.top: leftRowLayoutId.bottom
        anchors.left: parent.left
    }
}