import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"
Item { 
    width: 380
    Layout.fillHeight: true

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: cacheMouseArea.containsMouse ? Theme.color_r : Theme.color_2 
            radius: 10
            
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutCubic }}

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5
                
                Text {
                    text: "Caché"
                    color: Theme.text_color
                    font.pixelSize: 12
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: (sysManager.maintenanceInfo.cacheMb || 0).toFixed(1)
                    color: Theme.text_color
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "MB"
                    color: Theme.text_color
                    font.pixelSize: 10
                    opacity: 0.5
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            MouseArea {
                id: cacheMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { sysManager.cleanCache() }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: trashMouseArea.containsMouse ? Theme.color_r : Theme.color_2 
            radius: 10
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutCubic }}

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "Papelera"
                    color: Theme.text_color
                    font.pixelSize: 12
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: (sysManager.maintenanceInfo.trashMb || 0).toFixed(1)
                    color: Theme.text_color
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "MB"
                    color: Theme.text_color
                    font.pixelSize: 10
                    opacity: 0.5
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            MouseArea {
                id: trashMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { sysManager.cleanTrash() }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: logsMouseArea.containsMouse ? Theme.color_g : Theme.color_2 
            radius: 10
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutCubic }}

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "Logs"
                    color: Theme.text_color
                    font.pixelSize: 12
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: (sysManager.maintenanceInfo.logsMb || 0).toFixed(1)
                    color: Theme.text_color
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "MB"
                    color: Theme.text_color
                    font.pixelSize: 10
                    opacity: 0.5
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            MouseArea {
                id: logsMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { 
                    Qt.openUrlExternally("file:///var/log");
                    contentLoader.item.startCloseAnimation();
                }
            }
        }
    }
}