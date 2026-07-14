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
    property int marginScaled: 15 * scaleFactor
    y: 5
    width: ((appLauncher.open || appLauncher.animating)
        ? Math.max(leftRowLayoutId.implicitWidth + 80, appLauncher.width) 
        : leftRowLayoutId.implicitWidth + 30)
    height: ((appLauncher.open || appLauncher.animating)
            ? 38 + appLauncher.height
            : 38) * scaleFactor
    anchors {
        left: parent.left
        leftMargin: marginScaled
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
            leftMargin: marginScaled
            rightMargin: marginScaled
        }
        height: 38 * scaleFactor
        spacing: 8 * scaleFactor

        Rectangle {
            Layout.preferredHeight: parent.height - 5
            Layout.preferredWidth: btnAppLauncherContent.implicitWidth + 25 
            color: maAppLauncherBtn.containsMouse ? Theme.color_1 : "transparent"
            radius: 10 * scaleFactor
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }}
            RowLayout {
                id: btnAppLauncherContent
                anchors.fill: parent
                anchors.leftMargin: 10 * scaleFactor
                anchors.rightMargin: 10 * scaleFactor
                spacing: 5 * scaleFactor
                
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "\uf46d"
                    color: Theme.text_color
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "Apps"
                    color: Theme.color_b
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                id: maAppLauncherBtn
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Quickshell.ipc("appLauncher_" + modelData.name).toggle()
            }
        }
        Workspaces {
            Layout.fillWidth: true
            Layout.leftMargin: marginScaled
            Layout.alignment: Qt.AlignVCenter
        }
    }

    AppLauncher {
        id: appLauncher
        anchors.top: leftRowLayoutId.bottom
        anchors.left: parent.left
    }
}