import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"

Item {
    id: wallpaperSelector

    property bool open: false
    property bool animating: false
    property string wallpaperDir: Quickshell.env("WALLPAPER_DIR") 
        || (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/quickshell/wallpapers"

    focus: true
    width: 650
    height: (open || animating) && contentLoader.item ? contentLoader.item.popupHeight : 0
    visible: open || animating
    
    onOpenChanged: {
        if (open) { 
            contentLoader.active = true;
        } else {
            if(contentLoader.item){
                contentLoader.item.startCloseAnimation();
            }
        }
    }

    IpcHandler {
        target: "wallpaperSelector"
        function toggle(): void { wallpaperSelector.open = !wallpaperSelector.open }
        function show(): void { wallpaperSelector.open = true }
        function hide(): void { wallpaperSelector.open = false }
    }
    
    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: wallpaperContent
    }

    Component {
        id: wallpaperContent

        Item {
            id: internalRoot
            anchors.fill: parent
            readonly property int popupHeight: 400

            Component.onCompleted: {
                container.y = -internalRoot.popupHeight;
                wallpaperSelector.animating = true;
                openAnim.start();
            }

            function startCloseAnimation() {
                wallpaperSelector.animating = true;
                closeAnim.start();
            }
            Process {
                id: setWallpaper
            }

            Rectangle {
                id: container
                width: parent.width
                height: popupHeight
                color: Theme.color_1_solid
                radius: 10
                border {
                    color: Theme.color_3_solid
                    width: 1
                }
                
                FolderListModel {
                    id: wallpaperModel
                    folder: "file://" + wallpaperSelector.wallpaperDir
                    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.gif"]
                    showDirs: false
                }

                GridView {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: 12
                    cellWidth: 160
                    cellHeight: 100
                    model: wallpaperModel
                    clip: true
                    
                    delegate: Rectangle {
                        width: grid.cellWidth - 12
                        height: grid.cellHeight - 12
                        color: "transparent"
                        border.color: Theme.color_b
                        border.width: 1
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: fileUrl
                            sourceSize.width: grid.cellWidth - 13
                            sourceSize.height: grid.cellHeight - 13
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                setWallpaper.command = ["awww", "img", filePath, "--transition-type", "wipe", "--transition-duration", "1"]
                                setWallpaper.running = true
                                internalRoot.startCloseAnimation();
                            }
                        }
                    }
                }
            }
            ParallelAnimation {
                id: openAnim
                PropertyAnimation { 
                    target: container
                    property: "y"
                    to: 0
                    duration: 220
                    easing.type: Easing.OutCubic 
                }
                onStopped: { 
                    wallpaperSelector.animating = false; 
                }
            }

            ParallelAnimation {
                id: closeAnim
                PropertyAnimation { 
                    target: container
                    property: "y"
                    to: -internalRoot.popupHeight 
                    duration: 220
                    easing.type: Easing.InCubic 
                }
                onStopped: {
                    wallpaperSelector.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
}