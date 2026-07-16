import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"

Item {
    property var sysManager
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
                    text: "Reading"
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
                    text: "Writing"
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
                    text: "Health"
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