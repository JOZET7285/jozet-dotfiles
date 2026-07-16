import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"
import "../Modules/Today"

BasePopupBottom { 
    id: agendPopup
    customWidth: 320
    ipcTarget: "agendPopup"

    popupContent: Component {
        ColumnLayout {
            width: agendPopup.customWidth - 20
            spacing: 15

            Text {
                text: "New Task"
                font.pixelSize: 16
                font.bold: true
                color: Theme.text_color
            }

            TextField {
                id: taskInput
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                color: Theme.text_color
                font.pixelSize: 14
                background: Rectangle {
                    color: Theme.color_1
                    radius: 5
                }
                
                onAccepted: {
                    agendPopup.saveTask(taskInput.text)
                    taskInput.text = ""
                }

                Connections {
                    target: agendPopup
                    function onOpenChanged() {
                        if (agendPopup.open) {
                            taskInput.forceActiveFocus()
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 30
                    color: "transparent"
                    radius: 5
                    border.color: Theme.light_3
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Cancelar"
                        color: Theme.light_3
                        font.pixelSize: 13
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            taskInput.text = ""
                            agendPopup.open = false
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 30
                    color: Theme.color_b
                    radius: 5
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Guardar"
                        color: Theme.color_2
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            agendPopup.saveTask(taskInput.text)
                            taskInput.text = ""
                        }
                    }
                }
            }
        }
    }
    function saveTask(taskText) {
        if (taskText !== "") {
            sysManager.addAgendaTask(taskText);
            agendPopup.open = false;
        }
    }
}