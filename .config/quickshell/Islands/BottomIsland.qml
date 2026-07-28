import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../Components"
import Jozet.System 1.0

Rectangle {
    property bool activeHover: false
    property real positionX: 0.0
    anchors {
        bottom: parent.bottom
        bottomMargin: -2
    }
    x: {
        if (activeHover){
            if (positionX + ( width / 2 ) > modelData.width){
                return modelData.width-width;
            }
            else if (positionX - ( width / 2 ) < modelData.x) {
                return modelData.positionX - width/2;
            }
            else return positionX - (width / 2);
        }
        return 0;
    } 
    width: activeHover ? 250 : parent.width
    height: activeHover ? 33 * scaleFactor : 15 * scaleFactor
    color: Theme.color_1_solid
    
    border {
        width: 2
        color: Theme.color_3
    }
    topLeftRadius: 30
    topRightRadius: 30
    Behavior on color { ColorAnimation { duration: 250 } }
    Behavior on height { NumberAnimation { duration: 250 } }
    Behavior on width { NumberAnimation { duration: 200 } }

    Process {
        id: qsIpcCmd
    }

     function openPopupButton(popup) {
        qsIpcCmd.running = false; 
        qsIpcCmd.command = ["qs", "ipc", "call", `${popup}-${Hyprland.focusedMonitor.name}`, "toggle"];
        qsIpcCmd.running = true;
    }

    RowLayout {
        id: bottomRowLayoutId
        anchors.fill: parent
        visible: activeHover
        anchors{
            margins: 1
            leftMargin: 15 * scaleFactor
            rightMargin: 15 * scaleFactor
        }
        Button {
            id: wallpaperButton
            text: "\uf03e"
            Layout.fillWidth: true
            hoverEnabled: false
            onClicked: {
                openPopupButton('wallpaperSelector')
            }
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Text {
                text: wallpaperButton.text
                color: Theme.color_a_text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Button {
            id: eventsButton
            Layout.fillWidth: true
            hoverEnabled: false
            onClicked: {
                openPopupButton('eventPopup') 
            }
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Text {
                text: "\uf133"
                color: Theme.color_a_text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Button {
            id: agendaButton
            Layout.fillWidth: true
            hoverEnabled: false
            onClicked: {
                openPopupButton('agendaPopup') 
            }
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Text {
                text: "\uf02d"
                color: Theme.color_a_text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Button {
            id: notificationsButton
            Layout.fillWidth: true
            hoverEnabled: false
            onClicked: { 
            }
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Text {
                text: "\uf0f3"
                color: Theme.color_a_text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Button {
            id: settingsButton
            Layout.fillWidth: true
            hoverEnabled: false
            onClicked: {
                openPopupButton('settings') 
            }
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Text {
                text: "\uf013"
                color: Theme.color_a_text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    
}