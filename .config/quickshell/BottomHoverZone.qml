import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Components"
import "Popups"
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

    property bool floatingMode: SystemManager.getSetting("theme.panel.floating") === true
    property bool shinyEdge: SystemManager.getSetting("theme.panel.shiny_edge") === true
    property bool roundedCorners: SystemManager.getSetting("theme.panel.rounded_corners") === true

    Connections {
        target: SystemManager
        function onRiceSettingsChanged() {
            userScale = parseFloat(SystemManager.getSetting("theme.panel.size")) || 1.0
            rootUIBottom.floatingMode = SystemManager.getSetting("theme.panel.floating") === true
            rootUIBottom.shinyEdge = SystemManager.getSetting("theme.panel.shiny_edge") === true
            rootUIBottom.roundedCorners = SystemManager.getSetting("theme.panel.rounded_corners") === true
        }
    }

    anchors {
        bottom: true
    }
    implicitWidth: modelData ? modelData.width : 1920
    implicitHeight: 170
    exclusiveZone: 15
    color: "transparent"
    focusable: false

    mask: Region {
        Region { item: bottomLand }
        Region { item: hoverZone }
        Region { item: mediaIsland }
        Region { item: hoverMediaZone }
    }
    Item {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 20
        MouseArea {
            id: hoverMediaZone
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            height: mediaIsland.activeHover || mediaIsland.openPopup ? 40 : 5
            width: mediaIsland.width
            hoverEnabled: true

            onClicked: {
                mediaIsland.openPopup = !mediaIsland.openPopup
            }
        }
        MouseArea {
            id: hoverZone
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: hoverMediaZone.left
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
    }
    
    Item {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 30
        
        BottomIsland { 
            id: bottomLand
            activeHover: hoverZone.containsMouse
            anchors {
                bottom: parent.bottom
                bottomMargin: floatingMode ? 2 : -2
            }
            width: activeHover ? 250 * scaleFactor : parent.width - mediaIsland.width
            mediaWidth: SystemManager.mediaHasPlayer ? 200 : 0
            Behavior on width { NumberAnimation { duration: 200 } }
        }
        MultimediaIsland {
            id: mediaIsland
            activeHover: hoverMediaZone.containsMouse
            visible: SystemManager.mediaHasPlayer
            anchors {
                right: parent.right
                bottom: parent.bottom
                bottomMargin: floatingMode ? 2 : - 2
            }
        }
    }
}