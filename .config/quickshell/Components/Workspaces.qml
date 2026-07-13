import QtQuick
import Quickshell.Hyprland
import "."

Row {
    id: root
    spacing: 6
    property int workspaceCount: 10 * scaleFactor

    Repeater {
        model: root.workspaceCount

        Rectangle {
            id: wsDot
            required property int index

            property int wsId: index + 1
            property var wsData: Hyprland.workspaces.values.find(function(w) { return w.id === wsId })
            property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            property bool hasWindows: wsData !== undefined

            width: isActive ? 20 : 8
            height: 8
            radius: 4
            color: isActive ? Theme.color_b : (hasWindows ? Theme.light_1 : "transparent")
            border {
                width: hasWindows ? 0 : 1
                color: Theme.light_1
            }

            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 250 } } 

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsDot.wsId)
            }
        }
    }
}
