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
    id: rootUISys
    property string currentTime: "00:00"
    property string currentDate: ""
    property string playerState: "Pause"
    property bool playing: (mainProcesses.currentSongTitle === "Sin reproducción")

    property int notifPosition: parseInt(SystemManager.getSetting("display.notifications.position")) || 0
    property bool topNotify: notifPosition < 2
    property bool leftNotify: notifPosition % 2 === 0

    property var modelData 
    screen: modelData
    
    property real baseWidth: 1920
    property real scalePreFactor: modelData ? (modelData.width / baseWidth) : 1.0
    property real userScale: parseFloat(SystemManager.getSetting("theme.panel.size")) || 1.0
    property real scaleFactor: (scalePreFactor > 1.0 ? 1.0 : scalePreFactor) * userScale
    readonly property bool suggestCompact: scaleFactor < 0.8

    readonly property bool needsKeyboardFocus: anyPopupOpen

    Connections {
        target: SystemManager
        function onRiceSettingsChanged() {
            userScale = parseFloat(SystemManager.getSetting("theme.panel.size")) || 1.0
            
            let newPos = parseInt(SystemManager.getSetting("display.notifications.position"))
            notifPosition = isNaN(newPos) ? 0 : newPos

            rootUISys.floatingMode = SystemManager.getSetting("theme.panel.floating") === true
            rootUISys.shinyEdge = SystemManager.getSetting("theme.panel.shiny_edge") === true
            rootUISys.roundedCorners = SystemManager.getSetting("theme.panel.rounded_corners") === true
            rootUISys.alwaysVisibleMonitoring = SystemManager.getSetting("theme.panel.always_visible_monitoring") === true
        }
    }
    property bool floatingMode: SystemManager.getSetting("theme.panel.floating") === true
    property bool shinyEdge: SystemManager.getSetting("theme.panel.shiny_edge") === true
    property bool roundedCorners: SystemManager.getSetting("theme.panel.rounded_corners") === true
    property bool alwaysVisibleMonitoring: SystemManager.getSetting("theme.panel.always_visible_monitoring") === true

    focusable: needsKeyboardFocus
    WlrLayershell.keyboardFocus: needsKeyboardFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property var popupTopList: [leftLand.popups, rightLand.popups]
    property var popupList: [diskPopup, ramPopup, cpuPopup, tempPopup, todayPopup, settingsPopup] 
    property var popupBottomList: [agendPopup, wallpaperSelector, eventPopup, notificationPopup]
    property bool bottomPopupsOpened: (agendPopup.open || agendPopup.animating || 
                                       wallpaperSelector.open || wallpaperSelector.animating || 
                                       eventPopup.open || eventPopup.animating || 
                                       notificationPopup.open || notificationPopup.animating)

    property bool anyPopupOpen: {
        for (let i = 0; i < popupList.length; i++) {
            if (popupList[i].open || popupList[i].animating) return true
        }
        for (let i = 0; i < popupBottomList.length; i++) {
            if (popupBottomList[i].open || popupBottomList[i].animating) return true
        }
        return rightLand.popupOpened || leftLand.popupOpened
    }
    
    function closeOtherPopups(openedPopup) {
        if (openedPopup.open) {
            for (let i = 0; i < popupList.length; i++) {
                if (popupList[i] !== openedPopup && popupList[i].open) {
                    popupList[i].open = false;
                }
            }
            contentRoot.forceActiveFocus()
        }
    }
    function closeOtherBottomPopups(openedPopup) {
        if (openedPopup.open) {
            for (let i = 0; i < popupBottomList.length; i++) {
                if (popupBottomList[i] !== openedPopup && popupBottomList[i].open) {
                    popupBottomList[i].open = false;
                }
            }
            contentRoot.forceActiveFocus()
        }
    }
 
    function closeAllPopups() {
        for (let i = 0; i < popupList.length; i++) {
            if (popupList[i].open) popupList[i].open = false
        }
        for (let i = 0; i < popupBottomList.length; i++) {
            if (popupBottomList[i].open) popupBottomList[i].open = false
        }
        for (let i = 0; i < popupTopList.length; i++) {
            const group = popupTopList[i]
            if (!group) continue
            for (let j = 0; j < group.length; j++) {
                if (group[j] && group[j].open) group[j].open = false
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
        Region { item: (notificationPopup.open || notificationPopup.animating) ? notificationPopup : null }
        Region { item: (settingsPopup.open || settingsPopup.animating) ? settingsPopup : null }
        Region { item: notificationToast }
        Region { item: topHoverZone }
    }
    color: "transparent"
    
    HoverHandler { id: hoverPanelWindow } 

    MainProcess{ id: mainProcesses }

    Process {
        id: applyWallpaper
        onRunningChanged: {
            if (!running && wallpaperRetry.attempts < 2) {
                wallpaperRetry.running = true;
            }
        }
    }
    Timer {
        id: wallpaperTimer
        interval: 4000
        running: true
        repeat: false
        onTriggered: {
            var path = SystemManager.getSetting("theme.wallpaper_path");
            if (path && path !== "") {
                var monitor = modelData.name || "eDP-1";
                applyWallpaper.command = [
                    "awww", "img", path,
                    "-o", monitor,
                    "--transition-type", "wipe",
                    "--transition-duration", "1"
                ];
                applyWallpaper.running = true;
            }
        }
    }
    Timer {
        id: wallpaperRetry
        interval: 3000
        running: false
        repeat: false
        property int attempts: 0
        onTriggered: {
            var path = SystemManager.getSetting("theme.wallpaper_path");
            if (path && path !== "" && attempts < 2) {
                var monitor = modelData.name || "eDP-1";
                applyWallpaper.command = [
                    "awww", "img", path,
                    "-o", monitor,
                    "--transition-type", "wipe",
                    "--transition-duration", "1"
                ];
                applyWallpaper.running = true;
                attempts++;
            }
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
        id: topHoverZone
        anchors { 
            top: parent.top
            left: parent.left
            right: parent.right 
        }
        height: 8
        MouseArea { 
            id: topHoverArea
            anchors.fill: parent 
            hoverEnabled: true 
        }
    }

    Item {
        anchors.fill: parent
        focus: needsKeyboardFocus

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                closeAllPopups()
                event.accepted = true
            }
        }

        LeftMonitorIsland { 
            id: leftLandMonitor
            y: {
                if (!alwaysVisibleMonitoring) {
                    return (topHoverArea.containsMouse || leftLandMonitor.hovered) ? 5 * scaleFactor : -30 * scaleFactor
                }
                return 5 * scaleFactor
            } 
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }
        RightMonitorIsland { 
            id: rightLandMonitor
            y: {
                if (!alwaysVisibleMonitoring) {
                    return (topHoverArea.containsMouse || rightLandMonitor.hovered) ? 5 * scaleFactor : -30 * scaleFactor
                }
                return 5 * scaleFactor
            } 
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }
        LeftIsland { id: leftLand }
        MultimediaIsland { id: multimediaLand }
        CenterIsland { id: centerLand }
        RightIsland { id: rightLand }

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
            SettingsPopup {
                id: settingsPopup
                anchors.horizontalCenter: parent.horizontalCenter
                onOpenChanged: rootUISys.closeOtherPopups(this)
            }
        }
        Item {
            id: bottomPopupsContainer
            anchors {
                right: parent.right
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 40
            }
            AgendPopup {
                id: agendPopup
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                onOpenChanged: rootUISys.closeOtherBottomPopups(this)
            }
            WallpaperSelector {
                id: wallpaperSelector
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                onOpenChanged: rootUISys.closeOtherBottomPopups(this)
            }
            EventPopup {
                id: eventPopup
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                onOpenChanged: rootUISys.closeOtherBottomPopups(this)
            }
            NotificationPopup {
                id: notificationPopup
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 15
                onOpenChanged: rootUISys.closeOtherBottomPopups(this)
            }
        }
        NotificationToast {
            id: notificationToast
            anchors {
                top: topNotify ? (leftNotify ? leftLand.bottom : rightLand.bottom) : undefined
                bottom: !topNotify ? parent.bottom : undefined
                left: leftNotify ? parent.left : undefined
                right: !leftNotify ? parent.right : undefined
                
                topMargin: topNotify ? 12 : 40 * scaleFactor 
                rightMargin: 10
                bottomMargin: 25 * scaleFactor
                leftMargin: 10
            }
            z: 100
        }
    }
}

