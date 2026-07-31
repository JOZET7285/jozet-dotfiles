import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: notifySection

    ColumnLayout {
        spacing: 12
        Text { text: "Notifications"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color_3
            radius: 5
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8
                Text {
                    text: "General"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.text_color
                }
                RowLayout {
                    spacing: 10
                    Text { 
                        text: "Do not disturb:"
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                        Layout.preferredWidth: 100 
                    }
                    Rectangle {
                        Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                        color: Theme.color_1
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var current = SystemManager.getSetting("display.notifications.do_not_disturb")
                                SystemManager.setSetting("display.notifications.do_not_disturb", !current)
                                if(current) {
                                    notifyToggle.color = Theme.color_2
                                    notifyToggle.x = 2
                                } else {
                                    notifyToggle.color = Theme.color_a_text
                                    notifyToggle.x = 20
                                }
                            }
                        }
                        Rectangle {
                            id: notifyToggle
                            width: 18; height: 18; radius: 9
                            color: SystemManager.getSetting("display.notifications.do_not_disturb") ? Theme.color_a_text : Theme.color_3
                            x: SystemManager.getSetting("display.notifications.do_not_disturb") ? 20 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on x { NumberAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                }
                Text {
                    Layout.topMargin: 15
                    text: "Notification Card"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.text_color
                }
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "Position:"
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                    }
                    Repeater {
                        id: positionRepeater
                        property int selectedPosition: SystemManager.getSetting("display.notifications.position")

                        model: [
                            { key: 0, label: "Top L" },
                            { key: 1, label: "Top R" },
                            { key: 2, label: "Bot L" },
                            { key: 3, label: "Bot R" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            radius: 5
                            
                            color: Theme.color_4
                            
                            border.width: positionRepeater.selectedPosition === modelData.key ? 2 : 0
                            border.color: positionRepeater.selectedPosition === modelData.key ? Theme.color_a_text : Theme.color_3

                            Behavior on border.width { NumberAnimation { duration: 250 } }
                            Behavior on border.color { ColorAnimation { duration: 250 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: Theme.text_color
                                font.pixelSize: 12
                                font.bold: positionRepeater.selectedPosition === modelData.key
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SystemManager.setSetting("display.notifications.position", modelData.key)
                                    positionRepeater.selectedPosition = modelData.key
                                }
                            }
                        }
                    }
                }
            }
        }
                
        Item { Layout.fillHeight: true }
    }
}