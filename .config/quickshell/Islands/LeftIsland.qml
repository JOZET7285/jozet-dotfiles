import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Popups"
import "../Process"
import "../Modules/Panel"
import Jozet.System 1.0

Rectangle {
    property int marginScaled: 15 * scaleFactor
    property var popups: [appLauncher, workspacesPopup]
    property var activePopup: {
        for (var i = 0; i < popups.length; i++){
            var p = popups[i]
            if (p && (p.open || p.animating)) return p
        }
        return null
    }
    property var popupOpened: activePopup ? true : false
    property string currentMonitor: modelData.name

    width: (activePopup && (activePopup.open || activePopup.animating))
        ? Math.max(leftRowLayoutId.implicitWidth + 80, activePopup.width)
        : leftRowLayoutId.implicitWidth + 30
    height: ((activePopup && (activePopup.open || activePopup.animating))
        ? 38 + activePopup.height
        : 38) * scaleFactor
    anchors {
        left: parent.left
    }
    color: Theme.color_1_solid
    bottomRightRadius: 38
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
            color: "transparent"
            radius: 10 * scaleFactor
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
                onClicked: {
                    workspacesPopup.open = false
                    appLauncher.open = !appLauncher.open
                }
                cursorShape: Qt.pointingHandCursor
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: workspacesBtnPopup.implicitWidth + 25
            color: "transparent"
            Workspaces {
                id: workspacesBtnPopup
                anchors.centerIn: parent
            }
            MouseArea {
                id: maWorkspacesPopup
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    appLauncher.open = false
                    workspacesPopup.open = !workspacesPopup.open    
                }
                cursorShape: Qt.poitingHandCursor
            }
        }
    }
    WorkspacesPopup {
        id: workspacesPopup
        anchors.top: leftRowLayoutId.bottom
        anchors.left: parent.left
    }
    AppLauncher {
        id: appLauncher
        anchors.top: leftRowLayoutId.bottom
        anchors.left: parent.left
    }
}