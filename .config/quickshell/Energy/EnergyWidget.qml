import QtQuick
import Quickshell
import "../Components"

LayerSurface {
    id: root
    property string activeProfile: "balanced"
    function setProfile(profile) {
        activeProfile = profile
        Quickshell.exec("powerprofilesctl set " + profile)
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.border
        radius: Theme.borderRadius

        Column {
            CarbonButton {
                text: "Rendimiento"
                selected: activeProfile == "performance"
                onClicked: root.setProfile("performance")
            }
            CarbonButton {
                text: "Normal"
                selected: activeProfile == "balanced"
                onClicked: root.setProfile("balanced")
            }
            CarbonButton {
                text: "Ahorro de energía"
                selected: activeProfile == "power-saver"
                onClicked: root.setProfile("power-saver")
            }
        }
    }
}