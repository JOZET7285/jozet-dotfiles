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
    property string currentTime: "00:00"
    property string currentDate: ""
    property string playerState: "Pause"
    property bool playing: (mainProcesses.currentSongTitle === "Sin reproducción")

    property var modelData 
    screen: modelData
    
    property real baseWidth: 1920
    property real scalePreFactor: modelData ? (modelData.width / baseWidth) : 1.0
    property real scaleFactor: scalePreFactor > 1.0 ? 1.0 : scalePreFactor

    property var popupList: [diskPopup, ramPopup, cpuPopup, tempPopup, todayPopup] 
    property var popupBottomList: [agendPopup, wallpaperSelector, eventPopup]
    property bool bottomPopupsOpened: (agendPopup.open || agendPopup.animating || 
                                       wallpaperSelector.open || wallpaperSelector.animating || 
                                       eventPopup.open || eventPopup.animating)
    
    function closeOtherPopups(openedPopup) {
        if (openedPopup.open) {
            for (let i = 0; i < popupList.length; i++) {
                if (popupList[i] !== openedPopup && popupList[i].open) {
                    popupList[i].open = false;
                }
            }
        }
    }
    function closeOtherBottomPopups(openedPopup) {
        if (openedPopup.open) {
            for (let i = 0; i < popupBottomList.length; i++) {
                if (popupBottomList[i] !== openedPopup && popupBottomList[i].open) {
                    popupBottomList[i].open = false;
                }
            }
        }   
    }
    
    anchors {
        top: true
    }
    implicitWidth: modelData ? modelData.width : 1920
    implicitHeight: modelData ? modelData.height : 1080
    exclusiveZone: 40 * scaleFactor
    mask: Region {
        Region { item: leftLandMonitor }
        Region { item: leftLand }
        Region { item: multimediaLand }
        Region { item: centerLand }
        Region { item: rightLand }
        Region { item: rightLandMonitor }
        Region { item: (diskPopup.open || diskPopup.animating) ? diskPopup : null }
        Region { item: (wallpaperSelector.open || wallpaperSelector.animating) ? wallpaperSelector : null }
        Region { item: (ramPopup.open || ramPopup.animating) ? ramPopup : null }
        Region { item: (cpuPopup.open || cpuPopup.animating) ? cpuPopup : null }
        Region { item: (tempPopup.open || tempPopup.animating) ? tempPopup : null }
        Region { item: (todayPopup.open || todayPopup.animating) ? todayPopup : null }
        Region { item: (agendPopup.open || agendPopup.animating) ? agendPopup : null }
        Region { item: (eventPopup.open || eventPopup.animating) ? eventPopup : null }
    }
    color: "transparent"

    readonly property bool needsKeyboardFocus: rightLand.popupOpened || leftLand.popupOpened || bottomPopupsOpened

    focusable: needsKeyboardFocus
    WlrLayershell.keyboardFocus: needsKeyboardFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
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

        LeftMonitorIsland { id: leftLandMonitor }
        LeftIsland { id: leftLand }
        MultimediaIsland { id: multimediaLand }
        CenterIsland { id: centerLand }
        RightIsland { id: rightLand }
        RightMonitorIsland { id: rightLandMonitor }

        Item {
            id: centerPopupsContainer
            anchors {
                top: centerLand.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: 20
            }
            DiskPopup { 
                id: diskPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherPopups(this)
            }
            RamPopup { 
                id: ramPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherPopups(this) 
            }
            CpuPopup { 
                id: cpuPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherPopups(this) 
            }
            TempPopup { 
                id: tempPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherPopups(this) 
            }
            TodayPopup {
                id: todayPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherPopups(this)
            }
        }
        Item {
            id: bottomPopupsContainer
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 10
            }
            AgendPopup {
                id: agendPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherBottomPopups(this)
            }
            WallpaperSelector {
                id: wallpaperSelector
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherBottomPopups(this)
            }
            EventPopup {
                id: eventPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherBottomPopups(this)
            }
        }
        
    }
}

