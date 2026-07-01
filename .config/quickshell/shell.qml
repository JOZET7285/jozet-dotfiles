import Quickshell
import QtQuick

ShellRoot {
    Main {
        id: main
        Component.onCompleted: {
            globalThis.appLauncher = main.appLauncher
        }
    }
}