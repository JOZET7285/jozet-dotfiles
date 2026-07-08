import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components"

Rectangle {
    id: indicatorRoot
    Layout.preferredWidth: 95 
    Layout.fillWidth: false
    Layout.fillHeight: true

    readonly property bool isUp: connection.status === "up"

    color: isUp ? Theme.btn_color : Theme.bg_1
    radius: connection.type === "ethernet" ? 25 : 50
    
    border {
        width: 2
        color: isUp ? Theme.accent : Theme.bg_3
    }

    Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    Text {
        text: connection.type === "unknown" ? "\uf127" : connection.type === "ethernet" ? "\uf0e8" : "\uf1eb"
        color: indicatorRoot.isUp ? Theme.bg_2_solid : Theme.text_color
        font.pixelSize: 55
        anchors.centerIn: parent
        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    }
}
