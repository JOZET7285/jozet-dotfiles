// Components/CarbonButton.qml
import QtQuick

Rectangle {
    id: root
    width: 200; height: 40
    color: area.pressed || selected ? "#3c3c3c" : "#2b2b2b"
    radius: 4
    
    required property string text
    property bool selected: false
    signal clicked()

    Text { anchors.centerIn: parent; text: root.text; color: "white" }

    MouseArea {
        id: area
        anchors.fill: parent
        onClicked: root.clicked()
    }
}