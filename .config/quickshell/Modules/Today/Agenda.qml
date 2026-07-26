import Jozet.System 1.0
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
                color: Theme.text_color
            }
            Rectangle { 
                Layout.preferredHeight: 25
                Layout.preferredWidth: 25
                radius: 5
                color: addAgendaMa.containsMouse ? Theme.color_3 : Theme.color_1
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad}}
                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 15
                    font.bold: true
                    color: Theme.text_color
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
            model: SystemManager.agenda

            Connections {
                target: SystemManager
                function onTodayDataChanged() {
                    agendaList.model = null;
                    agendaList.model = SystemManager.agenda;
                }
            }
            
            delegate: RowLayout {
                width: parent.width
                
                Rectangle {
                    Layout.preferredWidth: 15
                    Layout.preferredHeight: 15
                    radius: 3
                    color: modelData.done ? Theme.color_a_text : "transparent"
                    border.color: modelData.done ? "transparent" : Theme.text_color
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad  }}
                    Behavior on border.color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }}
                    MouseArea {
                        anchors.fill: parent
                        onClicked: SystemManager.toggleAgendaTask(index)
                    }
                }
                Text {
                    Layout.margins: 10
                    text: modelData.task
                    color: modelData.done ? Theme.light_3 : Theme.text_color
                    font.strikeout: modelData.done
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    Behavior on font.strikeout { ColorAnimation { duration: 250 }}
                }
            }
        }
    }
}