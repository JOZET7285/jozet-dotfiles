import QtQuick
import Quickshell
import Quickshell.Io
import "./Energy" as EnergyModule

PanelWindow {
    id: masterWindow
    color: "transparent"
    
    // 1. Configuración de Capa (Overlay sobre todo)
    WlrLayershell.namespace: "qs-master"
    WlrLayershell.layer: WlrLayer.Overlay
    
    // 2. Puente de comunicación (IPC)
    // Aquí es donde Waybar y tus scripts le "hablan" al Main
    IpcHandler {
        target: "main"
        function handleCommand(cmd, widgetName) {
            if (cmd === "toggle") {
                // Lógica simple para mostrar/ocultar
                let target = widgetContainer.children[0];
                target.visible = !target.visible;
            }
        }
    }

    // Timer para desactivar la visibilidad lógica tras la animación
    Timer {
        id: hideTimer
        interval: 250 // Un poco más que la duración de la animación (200ms)
        onTriggered: masterWindow.visible = false
    }

    // 3. Contenedor de Widgets
    // Aquí cargarás tus componentes modulares
    Item {
        id: widgetContainer
        anchors.centerIn: parent
        width: 300; height: 200
        
        // Comportamiento: Si cambia la opacidad, anímala
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        // Comportamiento: Si cambia la escala, anímala
        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.OutBack }
        }

        opacity: isVisible ? 1.0 : 0.0
        scale: isVisible ? 1.0 : 0.95
        
        // Aquí instanciamos el widget
        EnergyModule.EnergyWidget {
            id: energyPanel
            visible: false
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