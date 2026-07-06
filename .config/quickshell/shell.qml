import Quickshell
import QtQuick
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
}