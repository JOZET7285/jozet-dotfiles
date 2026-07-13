import Quickshell
import QtQuick
import Quickshell.Io
import "Widgets"
import "Widgets/GlobalRefs.js" as GlobalRefs

ShellRoot {

    Variants {
        model: Quickshell.screens
        Main {
            Component.onCompleted: {
                if (typeof GlobalRefs.appLaunchers === "undefined") GlobalRefs.appLaunchers = {}
                GlobalRefs.appLaunchers[modelData.name] = appLauncher
            }
        }
    }

    Variants {
        model: Quickshell.screens
        WallpaperWidget {
            Component.onCompleted: {
                if (typeof GlobalRefs.wallpaperWidgets === "undefined") GlobalRefs.wallpaperWidgets = {}
                GlobalRefs.wallpaperWidgets[modelData.name] = this
            }
        }
    }

    Variants {
        model: Quickshell.screens
        WallpaperHoverZone {
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        Loader {
            active: false
            source: "WallpaperWidget.qml"
            
            Component.onCompleted: {
                if (typeof GlobalRefs.wallpaperLoaders === "undefined") GlobalRefs.wallpaperLoaders = []
                GlobalRefs.wallpaperLoaders.push(this)
            }
            
            onLoaded: {
                item.screen = currentScreen
                item.open = true 
                
                item.closeCompleted.connect(function() {
                    active = false
                })
            }
        }
    }

    IpcHandler {
        target: "wallpaperManager"
        
        function toggle() {
            if (typeof GlobalRefs.wallpaperLoaders === "undefined") return
            
            // Alterna el estado del loader en TODAS las pantallas
            for (var i = 0; i < GlobalRefs.wallpaperLoaders.length; i++) {
                var loader = GlobalRefs.wallpaperLoaders[i]
                if (loader.active) {
                    loader.item.open = false 
                } else {
                    loader.active = true 
                }
            }
        }
    }
}