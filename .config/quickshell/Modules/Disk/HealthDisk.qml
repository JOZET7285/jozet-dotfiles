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
            color: Theme.color_2
            radius: 10

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "Lectura"
                    color: Theme.text_color
                    font.pixelSize: 12
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: (sysManager.diskHealthAndIO.readSpeedMb || 0).toFixed(1)
                    color: Theme.text_color
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "MB/s"
                    color: Theme.text_color
                    font.pixelSize: 10
                    opacity: 0.5
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color_2
            radius: 10

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "Escritura"
                    color: Theme.text_color
                    font.pixelSize: 12
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: (sysManager.diskHealthAndIO.writeSpeedMb || 0).toFixed(1)
                    color: Theme.text_color
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "MB/s"
                    color: Theme.text_color
                    font.pixelSize: 10
                    opacity: 0.5
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color_2
            radius: 10

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "Salud"
                    color: Theme.text_color
                    font.pixelSize: 12
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: sysManager.diskHealthAndIO.health || "N/A"
                    color: Theme.text_color
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}