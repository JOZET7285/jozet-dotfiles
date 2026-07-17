import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"
ColumnLayout {
    Layout.fillWidth: true
    Layout.preferredHeight: 65
    spacing: 10
    
    RowLayout {
        Layout.fillWidth: true
        Layout.margins: 10
        spacing: 10
        Text {
            Layout.fillWidth: true
            text: "Upcoming Events"
            font.pixelSize: 14
            font.bold: true
            color: Theme.light_1
        }
        Rectangle { 
            Layout.fillHeight: true
            Layout.preferredWidth: height
            radius: 5
            color: addEventsMa.containsMouse ? Theme.color_2 : Theme.color_1
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad}}
            Text {
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: 15
                font.bold: true
                color: Theme.light_1
            }
            MouseArea {
                id: addEventsMa
                hoverEnabled: true
                anchors.fill: parent
                onClicked: eventPopup.open = !eventPopup.open
            }
        }
    }
    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        orientation: ListView.Horizontal
        spacing: 5
        clip: true
        model: sysManager.events ? sysManager.events : []
        
        delegate: Rectangle {
            width: 150
            height: 50
            color: Theme.color_1
            radius: 8
            
            ColumnLayout {
                anchors.centerIn: parent
                Text { 
                    text: modelData.date 
                    color: Theme.color_b 
                    font.bold: true 
                }
                Text { 
                    text: modelData.title 
                    color: Theme.text_color 
                    elide: Text.ElideRight 
                    Layout.maximumWidth: 130
                }
            }
        }
    }
}