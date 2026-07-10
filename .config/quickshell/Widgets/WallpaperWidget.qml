import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"

PanelWindow {
    id: wallpaperWidget
    visible: false

    anchors {
        bottom: true
        right: true
    }

    implicitHeight: 300
    implicitWidth: 480 
    color: "transparent"
    exclusiveZone: 0
    focusable: false

    property string wallpaperDir: Quickshell.env("WALLPAPER_DIR") 
        || (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/quickshell/wallpapers"

    property bool open: false
    property bool animating: false
    property bool visualOpen: false   

    onOpenChanged: {
        animating = true
        if (open) {
            visible = true
            Qt.callLater(() => { visualOpen = true })
        } else {
            visualOpen = false
        }
    }

    HoverHandler {
        id: widgetHover
        onHoveredChanged: {
            if (!hovered) wallpaperWidget.scheduleClose()
        }
    }

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: {
            if (!widgetHover.hovered) wallpaperWidget.open = false
        }
    }
    
    onVisibleChanged: {
        if (visible) closeTimer.stop()
    }

    function scheduleClose() {
        closeTimer.restart()
    }

    Process {
        id: ensureDir
        command: ["mkdir", "-p", wallpaperWidget.wallpaperDir]
        running: true
    }
    IpcHandler {
        target: "wallpaperWidget"
        function toggle(): void { wallpaperWidget.open = !wallpaperWidget.open }
        function show(): void { wallpaperWidget.open = true }
        function hide(): void { wallpaperWidget.open = false }
    }
    Item{
        anchors.fill: parent

        visible: open || animating

        Rectangle {
            id: container
            anchors {
                left: parent.left
                right: parent.right
            }
            height: parent.height
            topLeftRadius: Theme.radius
            color: Theme.color_1

            y: wallpaperWidget.visualOpen ? 0 : wallpaperWidget.height

            Behavior on y {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                    onRunningChanged: {
                        if (!running) {
                            animating = false
                            if (!wallpaperWidget.open) wallpaperWidget.visible = false
                        }
                    }
                }
            }

            FolderListModel {
                id: wallpaperModel
                folder: "file://" + wallpaperWidget.wallpaperDir
                nameFilters: ["*.jpg", "*.jpeg", "*.png"]
                showDirs: false
            }

            GridView {
                id: grid
                anchors.fill: parent
                anchors.margins: 12
                cellWidth: 160
                cellHeight: 100
                model: wallpaperModel

                delegate: Rectangle {
                    width: grid.cellWidth - 8
                    height: grid.cellHeight - 8
                    radius: Theme.radius
                    color: "transparent"
                    border.color: Theme.color_b
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: fileUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            setWallpaper.command = ["awww", "img", filePath, "--transition-type", "wipe", "--transition-duration", "1"]
                            setWallpaper.running = true
                        }
                    }
                }
            }
        }
    }
    Process { id: setWallpaper }
}