import QtQuick
import QtQuick.Controls
import ".."

Rectangle {
    id: root

    // Set `icon` to a Nerd Font glyph to show an icon.
    // Set `text` to show a label. You can use either, or both together.
    property string icon: ""
    property string text: ""
    property string tooltipText: ""
    property bool selected: false
    

    signal clicked()

    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: Theme.height - 6

    color: selected ? Theme.bg_2 : (area.containsMouse ? Theme.bg_hover : Theme.bg_1)
    radius: 8
    border.color: selected ? Theme.accent : "transparent"
    border.width: 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.icon.length > 0 && root.text.length > 0 ? 6 : 0

        Text {
            visible: root.icon.length > 0
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: 22
            color: root.selected ? Theme.accent : Theme.text_color
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: root.text.length > 0
            text: root.text
            horizontalAlignment: Text.AlignHCenter 
            verticalAlignment: Text.AlignVCenter
            color: root.selected ? Theme.accent : Theme.text_color
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ToolTip {
        visible: root.tooltipText.length > 0 && area.containsMouse
        text: root.tooltipText
        delay: 400
    }
}
