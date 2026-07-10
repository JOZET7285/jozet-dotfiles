import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components"

ColumnLayout {
    id: networkDetails
    required property var connection
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 8

    Repeater {
        model: [
            { 
                label: "Quality",
                show: "connection.type === 'wifi'" 
            },
            { 
                label: "Speed Connection",
                show: "true" 
            },
            { 
                label: "IP Address",
                show: "true" 
            }
        ]

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            
            Layout.topMargin: index === 0 ? 10 : 0
            Layout.bottomMargin: index === 2 ? 10 : 0

            color: Theme.color_2_solid
            radius: 12

            opacity: {
                if (index === 0) return networkDetails.connection.type === "wifi" ? 1.0 : 0.0;                
                return 1.0;            
            }
            visible: opacity > 0.0
            
            Behavior on opacity { 
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } 
            }

            Text {
                anchors.centerIn: parent
                text: {
                    if (index === 0) return "Quality: " + networkDetails.connection.qual + "% @ " + networkDetails.connection.freq;
                    if (index === 1) return "Speed Connection: " + networkDetails.connection.speed;
                    if (index === 2) return "IP Address: " + networkDetails.connection.address;
                    return "";
                }
                color: Theme.text_color
                font.pixelSize: 12
                font.bold: true
            }
        }
    }
}
