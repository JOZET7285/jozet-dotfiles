// shell.qml
import QtQuick
import Quickshell
import "Energy" as EnergyModule

ShellRoot {
    Main { id: masterWindow }
    TopBar {}
    Floating {}

    EnergyModule.EnergyWidget { 
        id: energyPanel
        visible: false 
    }
}