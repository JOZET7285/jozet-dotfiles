import QtQuick
import Quickshell
import Quickshell.Io
import "./Energy" as EnergyModule

PanelWindow {
    id: masterWindow
    color: "transparent"
    WlrLayershell.namespace: "qs-master"
    WlrLayershell.layer: WlrLayer.Overlay

    Timer {
        id: hideTimer
        interval: 250
        onTriggered: masterWindow.visible = false
    }

    Item {
        id: widgetContainer
        anchors.centerIn: parent
        width: 300; height: 200
        
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.OutBack }
        }

        opacity: masterWindow.visible ? 1.0 : 0.0
        scale: masterWindow.visible ? 1.0 : 0.95
        
        EnergyModule.EnergyWidget {
            id: energyPanel
            visible: true
            anchors.fill: parent
        }
    }

    IpcServer {
        name: "quickshell"

        onReceived: (client, message) => {
            if(message === "toggle"){
                masterWindow.visible = !masterWindow.visible;
            }
        }
    }
}