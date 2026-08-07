import QtQuick
import "../../Components"
import Jozet.System 1.0
import Quickshell

Row {
    id: root
    spacing: 6
    property int workspaceCount: 10
    
    property var currentMonitor: SystemManager.workspaces.length > 0 ? SystemManager.workspaces[0] : null
    
    property bool compactMode: SystemManager.getSetting("theme.panel.compact")
    
    property bool isSpecialActive: !!(currentMonitor && currentMonitor.specialWorkspace && currentMonitor.specialWorkspace.active)
    property int activeWorkspaceId: currentMonitor && currentMonitor.activeWorkspace ? currentMonitor.activeWorkspace.id : 1
    property string activeSpecialName: currentMonitor && currentMonitor.specialWorkspace ? currentMonitor.specialWorkspace.name : ""

    Connections {
        target: SystemManager
        function onRiceSettingsChanged() {
            compactMode = SystemManager.getSetting("theme.panel.compact") === true
        }
    }

    function toRomanNumber (number){
        const romanNumerals = {
            1: "I", 2: "II", 3: "III", 4: "IV", 5: "V",
            6: "VI", 7: "VII", 8: "VIII", 9: "IX", 10: "X"
        };
        return romanNumerals[number] || number.toString();
    }

    Repeater {
        model: root.workspaceCount

        Rectangle {
            required property int index  
            property int wsId: index + 1
            
            property bool hasWindows: {
                if (!root.currentMonitor || !root.currentMonitor.workspaces) return false;
                var ws = root.currentMonitor.workspaces.find(w => w.id === wsId);
                return !!(ws && ws.apps && ws.apps.length > 0);
            }
            
            property bool isActive: wsId === root.activeWorkspaceId

            visible: !root.isSpecialActive && (root.compactMode ? (isActive || hasWindows) : true)

            width: isActive ? 25 : 10
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
                onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "workspace " + wsId])
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

    Repeater {
        model: [
            { cmdName: "music", label: "M" },
            { cmdName: "terminal", label: "T" },
            { cmdName: "special", label: "S" } 
        ]
        
        Rectangle {
            required property var modelData
            
            property bool isActive: root.activeSpecialName === "special:" + modelData.cmdName || root.activeSpecialName === modelData.cmdName
            
            visible: root.isSpecialActive && (root.compactMode ? isActive : true)
            
            width: isActive ? 25 : 10
            height: 10
            radius: 5
            color: isActive ? Theme.color_a_text : Theme.light_4
            border {
                width: isActive ? 0 : 1
                color: Theme.light_4
            }

            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 250 } } 
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "togglespecialworkspace " + modelData.cmdName])
            }

            Text {
                anchors.centerIn: parent
                text: modelData.label
                font.pixelSize: 10
                color: Theme.isDark ? Theme.dark_1 : Theme.light_1
                font.bold: true
                visible: isActive
            }
        }
    }
}