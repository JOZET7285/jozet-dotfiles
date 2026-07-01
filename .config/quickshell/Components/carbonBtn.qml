// Components/CarbonButton.qml
import QtQuick
import "."

Rectangle {
    id: root
    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 40
    color: selected ? Theme.accent : (area.containsMouse ? Theme.bg_hover : Theme.bg_2)
    radius: 8
    border.color: selected ? Theme.accent : Theme.border_color
    border.width: 1

    required property string text
    property string icon: ""
    property bool selected: false
    signal clicked()

    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.icon.length > 0 ? 8 : 0

        Text {
            visible: root.icon.length > 0
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: 15
            color: root.selected ? "#ffffff" : Theme.text_color
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            color: root.selected ? "#ffffff" : Theme.text_color
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
