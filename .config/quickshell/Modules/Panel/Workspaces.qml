import QtQuick
import Quickshell.Hyprland
import "../../Components"
import Jozet.System 1.0

Row {
    id: root
    spacing: 6
    property int workspaceCount: 10 * scaleFactor
    property bool compactMode: SystemManager.getSetting("theme.panel.compact")

    Connections {
        target: SystemManager
        function onRiceSettingsChanged() {
            compactMode = SystemManager.getSetting("theme.panel.compact") === true
        }
    }
    function toRomanNumber (number){
        const romanNumerals = {
            1: "I",
            2: "II",
            3: "III",
            4: "IV",
            5: "V",
            6: "VI",
            7: "VII",
            8: "VIII",
            9: "IX",
            10: "X"
        };
        return romanNumerals[number] || number.toString();
    }

    Repeater {
        model: root.workspaceCount

        Rectangle {
            id: wsDot
            required property int index

            property int wsId: index + 1
            property var wsData: Hyprland.workspaces.values.find(function(w) { return w.id === wsId })
            property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            property bool hasWindows: wsData !== undefined

            width: isActive ? 25 : 10
            visible: compactMode ? (isActive || hasWindows) : true
            height: 10
            radius: 5
            color: isActive ? Theme.color_a_text : (hasWindows ? Theme.light_4 : "transparent")
            border {
                width: hasWindows ? 0 : 1
                color: Theme.light_4
            }

            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 250 } } 
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
            }

            Text {
                anchors.centerIn: parent
                text: toRomanNumber(wsId)
                font.pixelSize: 10
                color: Theme.isDark ? Theme.dark_1 : Theme.light_1
                font.bold: true
                visible: isActive
            }
        }
    }
}
