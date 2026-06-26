// shell.qml
import QtQuick
import Quickshell
import "Energy" as EnergyModule

ShellRoot {
    Main { id: masterWindow }

    EnergyModule.EnergyWidget { 
        id: energyPanel
        visible: false 
    }
}