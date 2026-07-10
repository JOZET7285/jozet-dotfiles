import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Components"
import "Popups"
import "Process"
import "Islands"
import Jozet.System 1.0

PanelWindow {
    id: rootUISys

    property bool popupOpen: leftLand.appLauncherOpen
    property string currentTime: "00:00"
    property string currentDate: ""
    property string playerState: "Pause"
    property bool playing: (mainProcesses.currentSongTitle === "Sin reproducción")

    
    anchors {
        top: true
    }
    implicitWidth: Screen.width
    implicitHeight: Theme.height + 15 + 570
    exclusiveZone: Theme.height
    mask: Region {
        Region { item: leftLandMonitor }
        Region { item: leftLand }
        Region { item: multimediaLand }
        Region { item: centerLand }
        Region { item: rightLand }
        Region { item: rightLandMonitor }
    }
    color: "transparent"
    focusable: false
    WlrLayershell.keyboardFocus: popupOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None    
    
    HoverHandler { id: hoverPanelWindow } 

    MainProcess{ id: mainProcesses }

    SystemManager{ 
        id: sysManager 
        Component.onCompleted: {
            sysManager.scanBluetooth(true)
        }    
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            mainProcesses.refreshAll()
        }
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            var now = new Date()
            currentTime = Qt.formatDateTime(new Date(), "hh:mm")
            currentDate = Qt.formatDateTime(now, "ddd, dd MMM")
        }
    }


    Item {
        anchors.fill: parent
        LeftMonitorIsland {
            id: leftLandMonitor
        }
        LeftIsland {
            id: leftLand
        }
        MultimediaIsland {
            id: multimediaLand
        }
        CenterIsland {
            id: centerLand
        }
        RightIsland {
            id: rightLand    
        }
        RightMonitorIsland {
            id: rightLandMonitor
        }
    }
}

