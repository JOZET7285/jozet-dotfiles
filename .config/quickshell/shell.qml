// ~/.config/quickshell/shell.qml
import QtQuick
import Quickshell
import "Energy"

ShellRoot {
    Main { id: masterWindow } 
    TopBar {}
    Floating {}

    EnergyWidget { 
        id: energyPanel
        visible: false 
    }
}