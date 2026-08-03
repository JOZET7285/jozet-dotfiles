import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Components/Pills"
import "../Popups"
import Jozet.System 1.0

Rectangle {
    id: container
    y: open ? (floatingMode ? 2 : -2) : -(height + 10)
    anchors {
        left: leftLand.right
        leftMargin: 15
    }
    width: mediaRowLayout.implicitWidth + 20
    height: 38 * scaleFactor
    color: Theme.color_1_solid
    radius: roundedCorners ? (floatingMode ? 10 : Theme.radius) : 0
    border.color: shinyEdge ? Theme.color_a_text : Theme.color_1
    border.width: 2
    clip: true
    visible: scaleFactor < 0.8 ? false : (open || animating)

    property bool open: SystemManager.playingApplications.length > 0
    property bool animating: false

    Behavior on y {
        NumberAnimation {
            id: yAnim
            duration: 220
            easing.type: container.open ? Easing.OutCubic : Easing.InCubic
            onRunningChanged: container.animating = running
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 120
        }
    }

    Behavior on color { ColorAnimation { duration: 250 } }
    Behavior on radius { NumberAnimation { duration: 250 } }
    Behavior on border.color { ColorAnimation { duration: 250 } }

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
            color: "transparent"
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