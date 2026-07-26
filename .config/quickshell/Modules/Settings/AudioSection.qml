import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../Components/"

Component {
    id: audioSection
    ColumnLayout {
        id: root
        spacing: 8

        property var devices: SystemManager.allPlaybackDevices
        property var inputDevices: SystemManager.allInputDevices
        property int selectedOutput: {
            for (let i = 0; i < devices.length; i++) {
                if (devices[i].isDefault) return devices[i].index
            }
            return -1
        }
        property int selectedInput: {
            for (let i = 0; i < inputDevices.length; i++) {
                if (inputDevices[i].isDefault) return inputDevices[i].index
            }
            return -1
        }
        property int selectedOutputVolume: {
            for (let i = 0; i < devices.length; i++) {
                if (devices[i].index === selectedOutput) return devices[i].volume
            }
            return 0
        }
        property int selectedInputVolume: {
            for (let i = 0; i < inputDevices.length; i++) {
                if (inputDevices[i].index === selectedInput) return inputDevices[i].volume
            }
            return 0
        }
        property bool selectedOutputMuted: {
            for (let i = 0; i < devices.length; i++) {
                if (devices[i].index === selectedOutput) return devices[i].isMuted
            }
            return false
        }
        property bool selectedInputMuted: {
            for (let i = 0; i < inputDevices.length; i++) {
                if (inputDevices[i].index === selectedInput) return inputDevices[i].isMuted
            }
            return false
        }

        Text { text: "Audio"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Text { text: "Output"; font.pixelSize: 13; font.bold: true; color: Theme.text_color }
        Repeater {
            model: root.devices
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                color: maOut.containsMouse ? Theme.color_3 : Theme.color_2
                Behavior on color { ColorAnimation { duration: 250 } }
                border.width: modelData.isDefault ? 1 : 0
                border.color: Theme.color_a_text
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    Text {
                        text: modelData.description || "No Devices"
                        font.pixelSize: 12
                        color: Theme.text_color
                        Layout.fillWidth: true
                    }
                    Text {
                        visible: modelData.isDefault
                        text: modelData.isMuted ? "Muted" : modelData.volume + "%"
                        font.pixelSize: 12
                        color: Theme.text_color
                    }
                }
                MouseArea {
                    id: maOut
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: !modelData.isDefault && SystemManager.setDefaultPlaybackDevice(modelData.index)
                }
            }
        }
        Slider {
            id: outputSlider
            Layout.fillWidth: true
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            from: 0; to: 100
            value: root.selectedOutputVolume
            onMoved: SystemManager.setDeviceVolume(root.selectedOutput, Math.round(value))
            background: Rectangle {
                implicitHeight: 6; height: implicitHeight
                y: (parent.height - height) / 2
                color: Theme.color_3; radius: 3
                Rectangle {
                    width: outputSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.color_y; radius: 3
                }
            }
            handle: Rectangle {
                x: outputSlider.leftPadding + outputSlider.visualPosition * (outputSlider.availableWidth - width)
                y: (outputSlider.height - height) / 2
                implicitWidth: 12; implicitHeight: 12; radius: 6
                color: outputSlider.pressed ? Theme.color_y_solid : Theme.color_y
            }
        }

        Item { Layout.preferredHeight: 8 }

        Text { text: "Input"; font.pixelSize: 13; font.bold: true; color: Theme.text_color }
        Repeater {
            model: root.inputDevices
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                color: maIn.containsMouse ? Theme.color_3 : Theme.color_2
                Behavior on color { ColorAnimation { duration: 250 } }
                border.width: modelData.isDefault ? 1 : 0
                border.color: Theme.color_a_text
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    Text {
                        text: modelData.description || "No Devices"
                        font.pixelSize: 12
                        color: Theme.text_color
                        Layout.fillWidth: true
                    }
                    Text {
                        visible: modelData.isDefault
                        text: modelData.isMuted ? "Muted" : modelData.volume + "%"
                        font.pixelSize: 12
                        color: Theme.text_color
                    }
                }
                MouseArea {
                    id: maIn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemManager.setDefaultInputDevice(modelData.index)
                }
            }
        }
        Slider {
            id: inputSlider
            Layout.fillWidth: true
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            from: 0; to: 100
            value: root.selectedInputVolume
            onMoved: SystemManager.setSourceDeviceVolume(root.selectedInput, Math.round(value))
            background: Rectangle {
                implicitHeight: 6; height: implicitHeight
                y: (parent.height - height) / 2
                color: Theme.color_3; radius: 3
                Rectangle {
                    width: inputSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.color_g; radius: 3
                }
            }
            handle: Rectangle {
                x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                y: (inputSlider.height - height) / 2
                implicitWidth: 12; implicitHeight: 12; radius: 6
                color: inputSlider.pressed ? Theme.color_g_solid : Theme.color_g
            }
        }

        Item { Layout.fillHeight: true }
    }
}
