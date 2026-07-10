import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Theme.color_2
    radius: 15

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: "Salida"
            color: Theme.text_color
            font.pixelSize: 12
            font.bold: true
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            color: Theme.color_1
            radius: 8

            Text {
                text: playbackDevice.description ? playbackDevice.description : "Ningún dispositivo"
                color: Theme.text_color
                font.pixelSize: 11
                anchors.centerIn: parent
            }
        }

        Slider {
            id: volumeSlider
            Layout.fillWidth: true
            from: 0
            to: 100
            value: playbackDevice ? playbackDevice.volume : 0
            onMoved: sysManager.setPlaybackVolume(Math.round(value))

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 4
                y: (parent.height - height) / 2
                color: Theme.color_3
                radius: 2

                Rectangle {
                    width: volumeSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.color_g
                    radius: 8
                }
            }

            handle: Rectangle {
                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                y: (volumeSlider.height - height) / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: Theme.color_g
            }
        }

        Text {
            text: playbackDevice ? playbackDevice.volume + "%" : "0%"
            color: Theme.text_color
            font.pixelSize: 10
            Layout.alignment: Qt.AlignHCenter
        }
    }
}