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
                        || rightLand.activePopup
    property string currentTime: "00:00"
    property string currentDate: ""
    property string playerState: "Pause"
    property bool playing: (mainProcesses.currentSongTitle === "Sin reproducción")

    property var modelData 
    screen: modelData
    
    property real baseWidth: 1920
    property real scaleFactor: modelData ? (modelData.width / baseWidth) : 1.0
    
    anchors {
        top: true
    }
    implicitWidth: modelData ? modelData.width : 1920
    implicitHeight: (50 * scaleFactor) + 570
    exclusiveZone: Theme.height * scaleFactor
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

