import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Components"

Rectangle {
    id: root
    property string activeProfile: "balanced"
    function setProfile(profile) {
        activeProfile = profile
        Quickshell.exec("powerprofilesctl set " + profile)
    }

    color: Theme.bg_1
    border.color: Theme.border_color
    radius: Theme.radius

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        CarbonButton {
            Layout.fillWidth: true
            icon: "\uf0e7" // nf-fa-bolt
            text: "Rendimiento"
            selected: root.activeProfile === "performance"
            onClicked: root.setProfile("performance")
        }
        CarbonButton {
            Layout.fillWidth: true
            icon: "\uf042" // nf-fa-adjust
            text: "Normal"
            selected: root.activeProfile === "balanced"
            onClicked: root.setProfile("balanced")
        }
        CarbonButton {
            Layout.fillWidth: true
            icon: "\uf06c" // nf-fa-leaf
            text: "Ahorro de energía"
            selected: root.activeProfile === "power-saver"
            onClicked: root.setProfile("power-saver")
        }
    }
}
