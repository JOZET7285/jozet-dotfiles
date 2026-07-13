import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components"

Rectangle {
    id: toggleRoot
    property var connection
    property var onConnectionTypeChanged
    Layout.fillWidth: true
    Layout.fillHeight: false
    Layout.preferredHeight: 40 * scaleFactor
    
    radius: 15
    color: Theme.color_3

    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 10

        Repeater {
            model: [
                { name: "ethernet", label: "Ethernet" },
                { name: "wifi", label: "Wi-fi" }
            ]

            delegate: Rectangle {
                id: buttonDelegate
                
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: 15
                border.width: 1

                readonly property bool isActive: toggleRoot.connection.type === modelData.name

                color: isActive ? Theme.color_2 : Theme.color_2_solid
                border.color: isActive ? Theme.color_g : mouseArea.containsMouse ? Theme.light_4: Theme.color_2

                Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                Text {
                    text: modelData.label
                    anchors.centerIn: parent
                    font.pixelSize: 14
                    font.bold: true
                    color: buttonDelegate.isActive ? Theme.color_g : Theme.text_color
                    
                    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (toggleRoot.onConnectionTypeChanged) {
                            toggleRoot.onConnectionTypeChanged(modelData.name);
                        }
                    }
                }
            }
        }
    }
}
