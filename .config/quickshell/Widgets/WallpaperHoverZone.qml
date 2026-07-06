import QtQuick
import Quickshell
import Quickshell.Wayland
import "GlobalRefs.js" as GlobalRefs
import "../Components"

PanelWindow {
    anchors { bottom: true; right: true }
    implicitHeight: 15
    implicitWidth: 480
    exclusiveZone: 0
    color: "transparent"

    /*HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                GlobalRefs.wallpaperWidget.open = true
            } else {
                GlobalRefs.wallpaperWidget.scheduleClose()
            }
        }
    }*/
    Rectangle{
        anchors.fill: parent
        color: mouseArea.containsMouse ? Theme.bg_1 : Theme.bg_2
        topLeftRadius: Theme.radius 
        Behavior on color {
            ColorAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        Text {
            anchors.centerIn: parent
            text: "Wallpapers"
            font.pixelSize: 10
            color: Theme.text_color
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                GlobalRefs.wallpaperWidget.open = true
            }
        }
    }
}