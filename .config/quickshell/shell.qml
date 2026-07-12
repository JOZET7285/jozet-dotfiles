import Quickshell
import QtQuick
import Quickshell.Io
import "Widgets"
import "Widgets/GlobalRefs.js" as GlobalRefs

ShellRoot {
    Main {
        id: main
        Component.onCompleted: {
            GlobalRefs.appLauncher = main.appLauncher
        }
    }

    WallpaperWidget {
        id: wallpaperWidget
        Component.onCompleted: {
            GlobalRefs.wallpaperWidget = wallpaperWidget
        }
    }

    WallpaperHoverZone {
        id: wallpaperHoverZone
    }
    Loader {
        id: wallpaperLoader
        active: false
        source: "WallpaperWidget.qml"
        
        onLoaded: {
            item.open = true 
            
            item.closeCompleted.connect(function() {
                active = false
            })
        }
    }
    IpcHandler {
        target: "wallpaperManager"
        
        function toggle() {
            if (wallpaperLoader.active) {
                wallpaperLoader.item.open = false 
            } else {
                wallpaperLoader.active = true 
            }
        }
    }
}