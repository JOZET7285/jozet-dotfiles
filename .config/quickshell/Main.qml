import QtQuick
import Quickshell
import Quickshell.Ipc
import Quickshell.Io
import "./Energy" as EnergyModule

PanelWindow {
    id: masterWindow
    color: "transparent"
    WlrLayershell.namespace: "qs-master"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardInteractivity: WlrLayer.OnDemand

    MouseArea {
        anchors.fill: parent
        onClicked: masterWindow.visible = false
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
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => mouse.accepted = true
            }
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

    // Se cierra si la ventana pierde el foco
    FocusScope {
        focus: true
        onFocusChanged: if (!focus) masterWindow.visible = false
    }
}