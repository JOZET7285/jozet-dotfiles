import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"

Rectangle {
    Layout.preferredWidth: 250
    Layout.fillHeight: true
    color: Theme.color_2
    radius: 15
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: "Tasks"
                font.pixelSize: 14
                font.bold: true
                color: Theme.light_1
            }
            Rectangle { 
                Layout.preferredHeight: 25
                Layout.preferredWidth: 25
                radius: 5
                color: addAgendaMa.containsMouse ? Theme.color_2 : Theme.color_1
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad}}
                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 15
                    font.bold: true
                    color: Theme.light_1
                }
                MouseArea {
                    id: addAgendaMa
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: agendPopup.open = !agendPopup.open
                }
            }
        }
        
        ListView {
            id: agendaList
            Layout.fillWidth: true
            Layout.fillHeight: true 
            clip: true
            model: sysManager.agenda

            Connections {
                target: sysManager
                function onTodayDataChanged() {
                    agendaList.model = null;
                    agendaList.model = sysManager.agenda;
                }
            }
            
            delegate: RowLayout {
                width: parent.width
                
                Rectangle {
                    Layout.preferredWidth: 15
                    Layout.preferredHeight: 15
                    radius: 3
                    color: modelData.done ? Theme.color_b : "transparent"
                    border.color: Theme.color_b
                    border.width: 1
                }
                
                Text {
                    Layout.margins: 10
                    text: modelData.task
                    color: modelData.done ? Theme.light_3 : Theme.text_color
                    font.strikeout: modelData.done
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}