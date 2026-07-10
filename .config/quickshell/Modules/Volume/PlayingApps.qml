import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: false
    Layout.preferredHeight: sysManager.playingApplications.length > 0 ? Math.min(appsLayout.implicitHeight + 12, 300) : 0
    color: Theme.bg_1
    radius: 15
    clip: true
    visible: sysManager.playingApplications.length > 0
    ScrollView {
        anchors.fill: parent
        anchors.margins: 1
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        contentHeight: appsLayout.implicitHeight

        ColumnLayout {
            id: appsLayout
            width: parent.width - 10
            anchors.margins: 5
            spacing: 8

            Repeater {
                model: sysManager.playingApplications
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    color: Theme.bg_2
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        BasePill {
                            text: modelData.icon
                            onClicked: sysManager.setApplicationMuted(modelData.pid, !modelData.isMuted)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: modelData.media || modelData.name
                                color: Theme.text_color
                                font.pixelSize: 11
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Slider {
                                id: volumeSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: modelData ? modelData.volume : 0
                                onMoved: sysManager.setApplicationVolume(modelData.pid, Math.round(value))

                                background: Rectangle {
                                    implicitWidth: 200
                                    implicitHeight: 4
                                    y: (parent.height - height) / 2
                                    color: Theme.bg_3
                                    radius: 2

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Theme.accent
                                        radius: 8
                                    }
                                }

                                handle: Rectangle {
                                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                    y: (volumeSlider.height - height) / 2
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    color: Theme.accent
                                }
                            }
                        }

                        Text {
                            text: modelData.volume + "%"
                            color: Theme.text_color
                            font.pixelSize: 10
                            Layout.preferredWidth: 30
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }
    }
}