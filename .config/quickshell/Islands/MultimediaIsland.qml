import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Components/Pills"
import "../Components/Buttons"
import "../Popups"
import Jozet.System 1.0

Rectangle {
    y: 5
    anchors {
        left: leftLand.right
        leftMargin: 15
    }    
    width: mediaRowLayout.implicitWidth + 20
    height: 38 * scaleFactor
    color: Theme.color_1
    radius: Theme.radius
    visible: scaleFactor < 0.8 ? false : !playing ? true : false
    Behavior on opacity {
        NumberAnimation{
            duration: 120
        }
    }
    RowLayout {
        id: mediaRowLayout
        anchors.fill: parent
        anchors {
            margins: 1
            leftMargin: 15
            rightMargin: 15
        }
        Rectangle {
            Layout.preferredWidth: 120 * scaleFactor
            Layout.preferredHeight: (Theme.height - 5) * scaleFactor
            Layout.alignment: Qt.AlignVCenter 
            
            color: Theme.color_2
            radius: Theme.radius - 5

            Text {
                anchors.fill: parent
                anchors.margins: 10
                
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                
                color: Theme.text_color
                elide: Text.ElideRight 
                text: mainProcesses.currentSongTitle
                
                font.pixelSize: 12 
            }
        }
        BasePillSimple {
            icon: "\uf04a"
            visible: !playing
            onClicked: mainProcesses.execute(["playerctl", "previous"])
        }

        BasePillSimple {
            id: playPauseBtn
            visible: !playing
            icon: mainProcesses.playerState ? "\uf04c" : "\uf04b"
            onClicked: mainProcesses.execute(["playerctl play-pause"]) 
        }

        BasePillSimple {
            icon: "\uf04e"
            visible: !playing
            onClicked: mainProcesses.execute(["playerctl", "next"])
        }
    }
}