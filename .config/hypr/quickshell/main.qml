import QtQuick
import Quickshell
import "Energy"

Scope {
    EnergyWidget { id: energyPanel; visible: false }

    Connections {
        target: Quickshell
        function onExecuteCommand(cmd) {
            if (cmd === "toggle-energy") {
                energyPanel.visible = !energyPanel.visible
            }
        }
    }
}