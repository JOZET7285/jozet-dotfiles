import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "GlobalRefs.js" as GlobalRefs // <-- 1. Importación añadida

PanelWindow {
    id: wallpaperWidget

    anchors {
        bottom: true
        right: true
    }
    margins {
        bottom: 15
    }

    implicitHeight: 300
    implicitWidth: 480 
    color: "transparent"
    exclusiveZone: 0
    focusable: false
    visible: false // <-- 2. Inicia oculto para no estorbar a Hyprland

    property string wallpaperDir: Quickshell.env("WALLPAPER_DIR") 
        || (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/quickshell/wallpapers"

    property bool open: false
    property bool animating: false
    property bool visualOpen: false   
    signal closeCompleted()

    Component.onCompleted: {
        GlobalRefs.wallpaperWidget = wallpaperWidget
    }

    // 3. Timer para asegurar que Wayland dibuje la ventana antes de animar
    Timer {
        id: waylandMapTimer
        interval: 20
        onTriggered: wallpaperWidget.visualOpen = true
    }

    onOpenChanged: {
        animating = true
        if (open) {
            visible = true
            contentLoader.active = true
            waylandMapTimer.start() // Reemplazo de Qt.callLater
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
    
    Process { id: setWallpaper }
    
    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: mainContent
    }
    
    Component {
        id: mainContent
        Item {
            anchors.fill: parent
            
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
                            if (!running && !wallpaperWidget.open) {
                                contentLoader.active = false
                                wallpaperWidget.visible = false
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
                            sourceSize.width: grid.cellWidth - 8
                            sourceSize.height: grid.cellHeight - 8
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
    }
}