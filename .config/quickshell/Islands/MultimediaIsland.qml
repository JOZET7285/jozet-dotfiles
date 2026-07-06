import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Components/Buttons"
import "../Popups"
import "../Process"
import Jozet.System 1.0

Rectangle {
    y: 5
    anchors {
        left: leftLand.right
        leftMargin: 15
    }
    width: mediaRowLayout.implicitWidth + 30
    height: Theme.height
    color: Theme.bg_2
    radius: Theme.radius
    visible: !mainProcess.playerState ? true : false
    RowLayout {
        id: mediaRowLayout
        anchors.fill: parent
        anchors {
            margins: 1
            leftMargin: 15
            rightMargin: 15
        }
        Rectangle {
            Layout.preferredWidth: 120
            Layout.preferredHeight: Theme.height - 7
            Layout.alignment: Qt.AlignVCenter 
            
            color: Theme.bg_1
            radius: Theme.radius - 5

            Text {
                anchors.fill: parent
                anchors.margins: 10
                
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                
                color: "white"
                elide: Text.ElideRight 
                text: mainProcesses.currentSongTitle
                
                font.pixelSize: 12 
            }
        }
        BasePill {
            icon: "\uf04a"
            visible: !playing
            onClicked: mainProcesses.execute(["playerctl", "previous"])
        }

        BasePill {
            id: playPauseBtn
            visible: !playing
            icon: mainProcesses.playerState ? "\uf04c" : "\uf04b"
            onClicked: mainProcesses.execute(["playerctl play-pause"]) 
        }

        BasePill {
            icon: "\uf04e"
            visible: !playing
            onClicked: mainProcesses.execute(["playerctl", "next"])
        }
    }
}