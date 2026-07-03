import QtQuick
import Quickshell.Hyprland
import "."

Row {
    id: root
    spacing: 6

    // How many workspace slots to always draw, even if empty/unused.
    property int workspaceCount: 10

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
            color: isActive ? Theme.accent : (hasWindows ? Theme.text_dim : Theme.border_color)

            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsDot.wsId)
            }
        }
    }
}
