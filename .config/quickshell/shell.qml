// ~/.config/quickshell/shell.qml
import QtQuick
import Quickshell
import "Energy/energyWidget.qml" as EnergyModule

ShellRoot {
    Main { id: masterWindow } 
    TopBar {}
    Floating {}

    EnergyModule.energyWidget { 
        id: energyPanel
        visible: false 
    }
}