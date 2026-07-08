import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components"

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 8

    Repeater {
        model: [
            { 
                text: "Quality: " + connection.qual + "% @ " + connection.freq, 
                show: connection.type === "wifi" 
            },
            { 
                text: "Speed Connection: " + connection.speed, 
                show: true 
            },
            { 
                text: "IP Address: " + connection.address, 
                show: true 
            }
        ]

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            
            Layout.topMargin: index === 0 ? 10 : 0
            Layout.bottomMargin: index === 2 ? 10 : 0

            color: Theme.bg_2_solid
            radius: 12

            opacity: modelData.show ? 1.0 : 0.0
            visible: opacity > 0.0
            
            Behavior on opacity { 
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } 
            }

            Text {
                anchors.centerIn: parent
                text: modelData.text
                color: Theme.text_color
                font.pixelSize: 12
                font.bold: true
            }
        }
    }
}
