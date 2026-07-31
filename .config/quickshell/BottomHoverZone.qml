import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Components"
import "Popups"
import "Process"
import "Islands"
import "Settings"
import Jozet.System 1.0

PanelWindow {
    id: rootUIBottom
    property var modelData 
    screen: modelData

    property real baseWidth: 1920
    property real scalePreFactor: modelData ? (modelData.width / baseWidth) : 1.0
    property real userScale: parseFloat(SystemManager.getSetting("theme.panel.size")) || 1.0
    property real scaleFactor: (scalePreFactor > 1.0 ? 1.0 : scalePreFactor) * userScale

    Connections {
        target: SystemManager
        function onRiceSettingsChanged() {
            userScale = parseFloat(SystemManager.getSetting("theme.panel.size")) || 1.0
        }
    }

    anchors {
        bottom: true
    }
    implicitWidth: modelData ? modelData.width : 1920
    implicitHeight: 30
    exclusiveZone: 10
    color: "transparent"
    focusable: false

    mask: Region {
        Region { item: bottomLand }
        Region { item: hoverZone }
    }
    MouseArea {
        id: hoverZone
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 5
        hoverEnabled: true
        onEntered: {
            bottomLand.positionX = mouseX 
            hoverZone.height = 20
        }
        onExited: {
            hoverZone.height = 5
        }
    }
    Item {
        anchors.fill: parent
        
        BottomIsland { 
            id: bottomLand
            activeHover: hoverZone.containsMouse
        }
    }
}