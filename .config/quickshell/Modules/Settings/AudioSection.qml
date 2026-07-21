import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: audioSection
    ColumnLayout {
        spacing: 12
        Text { text: "Audio"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Text { text: "Salida"; font.pixelSize: 13; font.bold: true; color: Theme.color_b }
        RowLayout {
            spacing: 10
            Text { text: sysManager.playbackDeviceInfo.name || "Sin dispositivo"; font.pixelSize: 12; color: Theme.text_color; Layout.fillWidth: true }
            Text { text: (sysManager.playbackDeviceInfo.isMuted ? "Muteado" : sysManager.playbackDeviceInfo.volume + "%"); font.pixelSize: 12; color: Theme.text_color }
        }
        Slider {
            id: inputSlider
            Layout.fillWidth: true
            from: 0
            to: 100
            value: sysManager.playbackDeviceInfo.volume
            onMoved: sysManager.setPlaybackVolume(Math.round(value))

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 6
                height: implicitHeight
                y: (parent.height - height) / 2
                color: Theme.color_3
                radius: 3

                Rectangle {
                    width: inputSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.color_y
                    radius: 8
                }
            }

            handle: Rectangle {
                x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                y: (inputSlider.height - height) / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: 6
                color: Theme.color_y
            }
        }

        Text { text: "Entrada"; font.pixelSize: 13; font.bold: true; color: Theme.color_b; Layout.topMargin: 10 }
        RowLayout {
            spacing: 10
            Text { text: sysManager.inputDeviceInfo.name || "Sin micrófono"; font.pixelSize: 12; color: Theme.text_color; Layout.fillWidth: true }
            Text { text: (sysManager.inputDeviceInfo.isMuted ? "Muteado" : sysManager.inputDeviceInfo.volume + "%"); font.pixelSize: 12; color: Theme.text_color }
        }
        Slider {
            id: outputSlider
            Layout.fillWidth: true
            from: 0
            to: 100
            value: sysManager.inputDeviceInfo.volume
            onMoved: sysManager.setPlaybackVolume(Math.round(value))

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 6
                height: implicitHeight
                y: (parent.height - height) / 2
                color: Theme.color_3
                radius: 3

                Rectangle {
                    width: outputSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.color_g
                    radius: 8
                }
            }

            handle: Rectangle {
                x: outputSlider.leftPadding + outputSlider.visualPosition * (outputSlider.availableWidth - width)
                y: (outputSlider.height - height) / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: 6
                color: Theme.color_g
            }
        }


        Item { Layout.fillHeight: true }
    }
}