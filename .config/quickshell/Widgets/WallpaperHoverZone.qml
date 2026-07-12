import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "GlobalRefs.js" as GlobalRefs
import "../Components"

PanelWindow {
    anchors { 
        bottom: true 
        right: true 
    }
    implicitHeight: 15
    implicitWidth: 480
    exclusiveZone: 0
    color: "transparent"
    Rectangle{
        anchors.fill: parent 
        color: mouseArea.containsMouse ? Theme.color_2 : Theme.color_1
        topLeftRadius: wallpaperWidget.open ? 0 : 90
        Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.OutCubic } }
        Behavior on topLeftRadius { NumberAnimation { duration: 500; easing.type: Easing.InOutCubic } }
        Text {
            anchors.centerIn: parent
            text: "Wallpapers"
            font.pixelSize: 10
            font.bold: true
            color: Theme.light_1
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (GlobalRefs.wallpaperWidget) {
                    GlobalRefs.wallpaperWidget.open = !GlobalRefs.wallpaperWidget.open
                }
            }
        }
    }
}