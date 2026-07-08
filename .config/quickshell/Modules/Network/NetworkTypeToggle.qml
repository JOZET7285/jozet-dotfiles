import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components"

Rectangle {
    id: toggleRoot
    Layout.fillWidth: true
    Layout.fillHeight: false
    Layout.preferredHeight: 40
    
    radius: 15
    color: Theme.bg_1

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

                readonly property bool isActive: connection.type === modelData.name

                color: isActive ? Theme.btn_color : Theme.bg_2
                border.color: isActive ? Theme.bg_1 : mouseArea.containsMouse ? Theme.accent : Theme.bg_1

                Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                Text {
                    text: modelData.label
                    anchors.centerIn: parent
                    font.pixelSize: 14
                    font.bold: true
                    color: buttonDelegate.isActive ? Theme.bg_2_solid : Theme.btn_color
                    
                    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (modelData.name === "ethernet") {
                            connection = sysManager.ethernetInfo;
                        } else {
                            connection = sysManager.wifiInfo;
                        }
                    }
                }
            }
        }
    }
}
