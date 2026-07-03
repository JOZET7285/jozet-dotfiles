import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Components"
import "Popups"
import "Process"

PanelWindow {
    id: rootAppLauncher

    property bool popupOpen: appLauncher.open
    property string currentTime: "00:00"
    property string currentDate: ""
    property string playerState: "Pause"
    property bool playing: (mainProcesses.currentSongTitle === "Sin reproducción")

    function toggle() {
        appLauncher.open = !appLauncher.open
    }
    anchors {
        top: true
    }
    width: Screen.width
    height: Theme.height + 15 + 570
    exclusiveZone: Theme.height + 15  
    mask: Region {
        Region { item: leftLandMonitor }
        Region { item: leftLand }
        Region { item: multimediaLand }
        Region { item: centerLand }
        Region { item: rightLand }
        Region { item: rightLandMonitor }
    }
    color: "transparent"
    
    HoverHandler { id: hoverPanelWindow } 

    MainProcess{ id: mainProcesses }

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

        // Isla de Monitoreo Izquierda ---------------------------
        Rectangle {
            id: leftLandMonitor
            y: 5
            width: leftRowLayoutMonitor.implicitWidth + 30
            height: Theme.height+5
            anchors {
                right: centerLand.left
                rightMargin: 15
            }
            color: Theme.bg_2
            border {
                width: 1
                color: Theme.bg_1
            }
            radius: Theme.radius
            clip: true
            Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
            RowLayout {
                id: leftRowLayoutMonitor
                anchors.fill: parent
                anchors{
                    margins: 1
                    leftMargin: 15
                    rightMargin: 15
                }
                spacing: 8
                // Memory
                BasePill {
                    icon: "\uf233"
                    text: mainProcesses.ramUsage + "%"
                }
                // Disk
                BasePill {
                    icon: "\uf0a0" 
                    text: mainProcesses.diskUsage + "%"
                }
            }
        }

        // Isla Izquierda ----------------
        Rectangle {
            id: leftLand
            y: 5
            width: (appLauncher.open || appLauncher.animating)
                ? Math.max(leftRowLayoutId.implicitWidth + 80, appLauncher.width) 
                : leftRowLayoutId.implicitWidth + 30
            height: (appLauncher.open || appLauncher.animating)
                    ? Theme.height + appLauncher.height
                    : Theme.height
            anchors {
                left: parent.left
                leftMargin: 15
            }
            color: Theme.bg_2
            border {
                width: 1
                color: Theme.bg_1
            }
            radius: Theme.radius
            clip: true

            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            RowLayout {
                id: leftRowLayoutId
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 1
                    leftMargin: 15
                    rightMargin: 15
                }
                height: Theme.height
                spacing: 8

                BasePill {
                    icon: "\uf00a"
                    text: "Apps"
                    selected: appLauncher.open
                    onClicked: appLauncher.open = !appLauncher.open
                }
                Workspaces {
                    Layout.leftMargin: 15
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            AppLauncher {
                id: appLauncher
                anchors.top: leftRowLayoutId.bottom
                anchors.left: parent.left
            }
        }

        Rectangle {
            id: multimediaLand
            y: 5
            anchors {
                left: leftLand.right
                leftMargin: 15
            }
            width: mediaRowLayout.implicitWidth + 30
            height: Theme.height
            color: Theme.bg_2
            border{
                width: 1
                color: Theme.bg_1
            }
            radius: Theme.radius
            RowLayout {
                id: mediaRowLayout
                anchors.fill: parent
                anchors {
                    margins: 1
                    leftMargin: 15
                    rightMargin: 15
                }
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: Theme.height - 7
                    Layout.alignment: Qt.AlignVCenter 
                    
                    color: Theme.bg_1
                    radius: Theme.radius - 5

                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        
                        color: "white"
                        elide: Text.ElideRight 
                        text: mainProcesses.currentSongTitle
                        
                        font.pixelSize: 12 
                    }
                }
                BasePill {
                    icon: "\uf049"
                    visible: !playing
                    onClicked: mainProcesses.execute(["playerctl", "previous"])
                }

                BasePill {
                    id: playPauseBtn
                    visible: !playing
                    icon: mainProcesses.playerState ? "\uf04c" : "\uf04b"
                    onClicked: mainProcesses.execute(["playerctl play-pause"]) 
                }

                BasePill {
                    icon: "\uf050"
                    visible: !playing
                    onClicked: mainProcesses.execute(["playerctl", "next"])
                }
            }
        }

        // Isla Central ---------------------------------
        Rectangle {
            id: centerLand
            y: 5
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: centerRowLayoutId.implicitWidth + 30
            height: Theme.height+10
            color: Theme.bg_2
            border {
                width: 1
                color: Theme.bg_1
            }
            radius: Theme.radius

            RowLayout {
                id: centerRowLayoutId
                anchors.fill: parent
                anchors{
                    margins: 1
                    leftMargin: 15
                    rightMargin: 15
                }
                BasePill { 
                    icon: "\uf017"; 
                    text: currentTime +"   |   "+currentDate
                }
                BasePill { 
                    id: basePillClima
                    icon: "\uf0c2"
                    text: "Clima"
                }
            }
        }

        // Isla Derecha ----------------------------
        Rectangle {
            id: rightLand
            y: 5
            height: Theme.height
            width: rightRowLayoutId.implicitWidth + 40
            anchors {
                right: parent.right
                rightMargin: 15
            }
            color: Theme.bg_2
            border {
                width: 1
                color: Theme.bg_1
            }
            radius: Theme.radius
            
            RowLayout {
                id: rightRowLayoutId
                anchors.fill: parent
                anchors{
                    margins: 1
                    leftMargin: 15
                    rightMargin: 15
                }
                spacing: 8
                BasePill {
                    id: bpInternet
                    icon: {
                        if (mainProcesses.netStatus === "Ethernet") return "\uf0e8"
                        if (mainProcesses.netStatus === "Wi-Fi") return "\uf1eb"
                        return "\uf127"
                    }
                }
                BasePill {
                    id: bpBluetooth
                    icon: "\uf293"
                    text: ""
                }
                BasePill {
                    icon: "\uf185"
                }
                BasePill {
                    icon: {
                        if(mainProcesses.volumePercent === "mute") return "\uf6a9"
                        if(mainProcesses.volumePercent > 60) return "\uf028"
                        if(mainProcesses.volumePercent > 30) return "\uf027"
                        return "\uf026"
                    }
                }
                BasePill {
                    icon: {
                        if (mainProcesses.batteryPercent === "charging") return "\uf0e7"
                        if (mainProcesses.batteryPercent > 80) return "\uf240"
                        if (mainProcesses.batteryPercent > 60) return "\uf241"
                        if (mainProcesses.batteryPercent > 40) return "\uf242"
                        if (mainProcesses.batteryPercent > 20) return "\uf243"
                        return "\uf244"
                    }
                }
                // Ejemplo para el botón de Ajustes
                BasePill {
                    icon: "\uf013"
                 }

                // Ejemplo para el botón de Power
                BasePill {
                    icon: "\uf011"
                }
            }
        }

        // Isla de Monitoreo Derecha --------------------------
        Rectangle {
            id: rightLandMonitor
            y: 5
            width: rightRowLayoutMonitor.implicitWidth + 10
            height: Theme.height+5
            anchors {
                left: centerLand.right
                leftMargin: 15
            }
            radius: Theme.radius
            color: Theme.bg_2
            border {
                width: 1
                color: Theme.bg_1
            }
            clip: true
            Behavior on width {NumberAnimation {duration: 750; easing.type: Easing.OutCubic }}
            RowLayout {
                id: rightRowLayoutMonitor
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8
                // cpu
                BasePill {
                    icon: "\uf2db"
                    text: mainProcesses.cpuUsage + "%"
                }
                // temp
                BasePill {
                    icon: "\uf2c9"
                    text: mainProcesses.cpuTemp + "°C"
                }
            }
        }

        state: (hoverPanelWindow.hovered || popupOpen) ? "SEPARADO" : "CENTRADOS"

        states: [
            State {
                name: "CENTRADOS"
            },
            State {
                name: "SEPARADO"
            }
        ]

        transitions: [
            Transition {
                from: "*"; to: "*"
                AnchorAnimation { duration: 750; easing.type: Easing.OutCubic }
                NumberAnimation { 
                    properties: "leftMargin,rightMargin,left,right,anchors,visible,y,"; 
                    duration: 750; 
                    easing.type: Easing.OutCubic 
                }
            }
        ]
    }
}

