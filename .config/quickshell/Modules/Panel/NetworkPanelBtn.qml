import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Components"
import "../../Popups"
import "../Process"
import Jozet.System 1.0

Rectangle {
    id: networkBtn
    implicitWidth: networkPopup.open ? parent.width : contentRow.implicitWidth+20
    implicitHeight: Theme.height - 6
    color: (networkBtn.selected ? Theme.bg_3 : (area.containsMouse ? Theme.bg_2 : "transparent"))
    radius: networkBtn.selected ? Theme.radius : 8 
    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
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
        spacing: 6
        Text{
            text: (connection.type == "ethernet" ? "\uf0e8" : connection.type == "wifi" ? "\uf1eb" : "\uf127")
            color: Theme.text_color
        }
        Text{
            text: connection.name !== "" ? connection.name : (connection.type == "ethernet" ? "Ethernet" : connection.type == "wifi" ? "Wi-Fi" : "No connection")
            color: Theme.text_color
        }
        visible: activePopup == null || activePopup == networkPopup
    }
}