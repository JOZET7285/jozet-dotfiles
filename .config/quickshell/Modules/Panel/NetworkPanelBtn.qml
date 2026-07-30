import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Components"
import "../../Popups"
import Jozet.System 1.0

Rectangle {
    id: networkBtn
    implicitWidth: networkPopup.open ? parent.width : contentRow.implicitWidth+20
    implicitHeight: (Theme.height - 5)* scaleFactor
    color: "transparent"
    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

    property bool compactMode: SystemManager.getSetting("theme.panel.compact") === true

    Connections {
        target: SystemManager
        function onRiceSettingsChanged() {
            compactMode = SystemManager.getSetting("theme.panel.compact") === true
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: networkPopup.open = !networkPopup.open
    }
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8
        Text{
            text: (connection.type == "ethernet" ? "\uf0e8" : connection.type == "wifi" ? "\uf1eb" : "\uf127")
            color: connection.type == "unknown" ? Theme.color_r : Theme.text_color
            font.pixelSize: 14
        }
        Text{
            visible: compactMode ? area.containsMouse : true
            text: connection.name !== "" ? connection.name : (connection.type == "ethernet" ? "Ethernet" : connection.type == "wifi" ? "Wi-Fi" : "No connection")
            color: connection.type == "unknown" ? Theme.color_r : Theme.color_a_text
            font.bold: true
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
        visible: activePopup == null || activePopup == networkPopup
    }
}