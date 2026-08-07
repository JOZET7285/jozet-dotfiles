import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"

BasePopupBottom {
    id: wallpaperSelector
    
    property url wallpaperFolder: {
        let envDir = Quickshell.env("WALLPAPER_DIR");
        if (envDir) return "file://" + envDir;
        
        let configHome = Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.local");
        return "file://" + configHome + "/share/jzt/assets/wallpapers";
    }
    property string currentMonitor: modelData.name

    customWidth: 684
    customHeight: 400
    ipcTarget: "wallpaperSelector-" + currentMonitor

    Process {
        id: setWallpaper
    }
    Process {
        id: runMatugen
    }

    popupContent: Component {
        Item {
            anchors.fill: parent

            FolderListModel {
                id: wallpaperModel
                folder: wallpaperSelector.wallpaperFolder
                nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp"]
                showDirs: false
            }

            GridView {
                id: grid
                focus: true
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
                    border.color: Theme.color_a_text
                    border.width: 2
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: model.fileUrl 
                        sourceSize.width: grid.cellWidth - 13
                        sourceSize.height: grid.cellHeight - 13
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            setWallpaper.command = [
                                "awww", "img", model.filePath, 
                                "-o", currentMonitor,
                                "--transition-type", "wipe", 
                                "--transition-duration", "1"
                            ]
                            setWallpaper.running = true

                            SystemManager.setSetting("theme.wallpaper_path", model.filePath)
                            
                            wallpaperSelector.open = false 

                            var mode = SystemManager.riceSettings.theme.mode
                            runMatugen.command = ["sh", "-c",
                                "matugen image '" + model.filePath + "' -m " + mode + " -j hex --prefer darkness 2>/dev/null"]
                            
                            runMatugen.running = true
                        }
                    }
                }
            }
        }
    }
}
