import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "Components"
import "Popups"

PanelWindow {
    id: rootAppLauncher

    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0
    property int cpuTemp: 0
    property string currentTime: "00:00"
    property string currentDate: ""
    property bool popupOpen: appLauncher.open
    function toggle() {
        appLauncher.open = !appLauncher.open
    }
    anchors {
        top: true
    }
    width: Screen.width
    height: Theme.height+10
    color: "transparent"

    AppLauncher {
        id: appLauncher
    }
    
    HoverHandler {
        id: hoverPanelWindow
    }
 
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                
                // Cálculo del porcentaje de RAM utilizada
                ramUsage = Math.round(100 * used / total)
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "top -b -n 2 -d 0.2 | grep '%Cpu' | tail -1 | awk '{print int(100 - $8)}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var cleanData = data.trim()
                var parsed = parseInt(cleanData)
                if (!isNaN(parsed)) {
                    cpuUsage = parsed
                }
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: diskProc
        command: ["sh", "-c", "df /home | awk 'NR==2 {print $5}' | sed 's/%//'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var cleanData = data.trim()
                var parsed = parseInt(cleanData)
                if (!isNaN(parsed)) {
                    diskUsage = parsed
                }
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp | awk '{print int($1/1000)}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var cleanData = data.trim()
                var parsed = parseInt(cleanData)
                if (!isNaN(parsed)) {
                    cpuTemp = parsed
                }
            }
        }
        Component.onCompleted: running = true
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

    Timer {
        id: monitoringTimer
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            if (!memProc.running) memProc.running = true
            if (!cpuProc.running) cpuProc.running = true
            if (!diskProc.running) diskProc.running = true
            if (!tempProc.running) tempProc.running = true
        }
    }
    Item {
        anchors.fill: parent
        Rectangle {
            id: leftLandMonitor
            x: 10 
            y: -50
            width: leftRowLayoutMonitor.implicitWidth+10
            height: Theme.height
            color: Theme.bg_1
            radius: Theme.radius
            clip: true
            Behavior on width {NumberAnimation {duration: 180; easing.type: Easing.OutCubic }}
            RowLayout {
                id: leftRowLayoutMonitor
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8
                // Memory
                BasePill {
                    icon: "\uf233"
                    text: ramUsage + "%"
                }
                // Disk
                BasePill {
                    icon: "\uf0a0" 
                    text: diskUsage + "%"
                }
            }
        }
    }
    Item {
        anchors.fill: parent
        Rectangle {
            id: rightLandMonitor
            x: screen.width - rightLandMonitor.width -10
            y: -50
            width: rightRowLayoutMonitor.implicitWidth + 10
            height: Theme.height
            color: Theme.bg_1
            radius: Theme.radius
            clip: true
            Behavior on width {NumberAnimation {duration: 180; easing.type: Easing.OutCubic }}
            RowLayout {
                id: rightRowLayoutMonitor
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8
                // cpu
                BasePill {
                    icon: "\uf2db"
                    text: cpuUsage + "%"
                }
                // temp
                BasePill {
                    icon: "\uf2c9"
                    text: cpuTemp + "°C"
                }
            }
        }
    }


    Item {
        anchors.fill: parent

        // Isla Izquierda ----------------
        Rectangle {
            id: leftLand
            y: 5
            width: leftRowLayoutId.implicitWidth + 10
            height: Theme.height
            color: Theme.bg_1
            radius: Theme.radius
            clip: true
            
            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            RowLayout {
                id: leftRowLayoutId
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8

                BasePill {
                    icon: "\uf00a"
                    selected: appLauncher.open
                    visible: hoverPanelWindow.hovered || popupOpen
                    onClicked: {
                        appLauncher.open = !appLauncher.open
                    }
                }

                Workspaces {
                    Layout.leftMargin: (hoverPanelWindow.hovered || appLauncher.open) ? 0 : 15                    
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        // Isla Central ---------------------------------
        Rectangle {
            id: centerLand
            y: 5
            width: centerRowLayoutId.implicitWidth + 10
            anchors.horizontalCenter: parent.horizontalCenter 
            height: Theme.height
            color: Theme.bg_1
            radius: Theme.radius

            RowLayout {
                id: centerRowLayoutId
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8
                BasePill { 
                    icon: "\uf017"; 
                    text: currentTime +"\n"+currentDate
                }
                // Item { Layout.fillWidth: true }
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
            width: rightRowLayoutId.childrenRect.width + 40
            height: Theme.height
            color: Theme.bg_1
            radius: Theme.radius

            RowLayout {
                id: rightRowLayoutId
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8
                BasePill {
                    icon: "\uf1eb"
                    tooltipText: "Internet"
                }
                BasePill {
                    icon: "\uf293"
                    tooltipText: "Bluetooth"
                }
            }
        }

        state: (hoverPanelWindow.hovered || popupOpen) ? "SEPARADO" : "CENTRADOS"

        states: [
            State {
                name: "CENTRADOS"
                AnchorChanges { target: centerLand; anchors.horizontalCenter: parent.horizontalCenter }
                AnchorChanges { target: leftLand; anchors.right: centerLand.left }
                AnchorChanges { target: rightLand; anchors.left: centerLand.right }
                PropertyChanges { target: leftLand; anchors.rightMargin: 12 }
                PropertyChanges { target: rightLand; anchors.leftMargin: 12 }
                PropertyChanges { target: leftLandMonitor; visible: true; y: 5 }
                PropertyChanges { target: rightLandMonitor; visible: true; y: 5 }
            },
            State {
                name: "SEPARADO"
                AnchorChanges { target: leftLand; anchors.left: parent.left }
                AnchorChanges { target: centerLand; anchors.horizontalCenter: parent.horizontalCenter }
                AnchorChanges { target: rightLand; anchors.right: parent.right }
                PropertyChanges { target: leftLand; anchors.leftMargin: 15 }
                PropertyChanges { target: rightLand; anchors.rightMargin: 15 }
                PropertyChanges { target: leftLandMonitor; visible: false; y: -50}
                PropertyChanges { target: rightLandMonitor; visible: false; y: -50}
            }
        ]

        transitions: [
            Transition {
                from: "*"; to: "*"
                AnchorAnimation { duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { properties: "leftMargin,rightMargin,y,visible,x,left,right,horizontalCenter"; duration: 300; easing.type: Easing.OutCubic }
            }
        ]
    }
}

