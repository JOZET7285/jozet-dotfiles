import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"
import "../Modules/Today"

BasePopupBottom { 
    id: eventPopup
    customWidth: 320
    ipcTarget: "eventPopup"

    popupContent: Component {
        ColumnLayout {
            width: eventPopup.customWidth - 20
            spacing: 15

            Text {
                text: "New Event"
                font.pixelSize: 16
                font.bold: true
                color: Theme.text_color
            }

            TextField {
                id: dateInput
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                placeholderText: "Date (YYYY-MM-DD)"
                color: Theme.text_color
                font.pixelSize: 14
                background: Rectangle {
                    color: Theme.color_3
                    radius: 5
                }
                onAccepted: titleInput.forceActiveFocus()

                Connections {
                    target: eventPopup
                    function onOpenChanged() {
                        if (eventPopup.open) {
                            dateInput.forceActiveFocus()
                        }
                    }
                }
            }

            TextField {
                id: titleInput
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                placeholderText: "Title"
                color: Theme.text_color
                font.pixelSize: 14
                background: Rectangle {
                    color: Theme.color_3
                    radius: 5
                }
                onAccepted: {
                    eventPopup.saveEvent(dateInput.text, titleInput.text)
                    dateInput.text = ""
                    titleInput.text = ""
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
                        text: "Cancel"
                        color: Theme.light_3
                        font.pixelSize: 13
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dateInput.text = ""
                            titleInput.text = ""
                            eventPopup.open = false
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
                            eventPopup.saveEvent(dateInput.text, titleInput.text)
                            dateInput.text = ""
                            titleInput.text = ""
                        }
                    }
                }
            }
        }
    }

    function saveEvent(date, title) {
        if (date.trim() !== "" && title.trim() !== "") {
            sysManager.addEvent(date, title);
            eventPopup.open = false;
        }
    }
}