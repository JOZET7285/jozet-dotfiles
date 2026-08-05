import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../Components"
import "../Components/Pills"
import Jozet.System 1.0

Rectangle {
    id: popup

    property bool open: false
    property bool closing: false
    property real marginScaled: 10 * scaleFactor

    Layout.fillWidth: true
    Layout.preferredHeight: open ? 120 : 0

    color: "transparent"
    clip: true
    visible: open || closing

    Behavior on Layout.preferredHeight { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: closing = false
    }

    onOpenChanged: {
        if (!open) {
            closing = true
            closeTimer.restart()
        }
    }

    function formatTime(us) {
        var totalSeconds = Math.floor(us / 1000000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: marginScaled
        spacing: 10 * scaleFactor

        Item {
            Layout.preferredWidth: 56 * scaleFactor
            Layout.preferredHeight: 56 * scaleFactor

            Rectangle {
                id: artPlaceholder
                anchors.fill: parent
                radius: 8
                color: Theme.color_3
                visible: SystemManager.mediaArtUrl === ""
                Text {
                    anchors.centerIn: parent
                    text: "\uf001"
                    font.family: Theme.iconFont
                    font.pixelSize: 22 * scaleFactor
                    color: Theme.text_color
                }
            }

            Image {
                id: artImage
                anchors.fill: parent
                source: SystemManager.mediaArtUrl
                fillMode: Image.PreserveAspectCrop
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: artImage
                maskEnabled: true
                maskSource: artMask
            }
            Item {
                id: artMask
                width: parent.width
                height: parent.height
                visible: false
                layer.enabled: true
                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: Theme.color_1_solid
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6 * scaleFactor

            ColumnLayout {
                spacing: 2 * scaleFactor
                Text {
                    Layout.fillWidth: true
                    text: SystemManager.mediaTitle
                    color: Theme.color_a_text
                    font { bold: true; pixelSize: 12 * scaleFactor }
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                Text {
                    Layout.fillWidth: true
                    text: SystemManager.mediaArtist + (SystemManager.mediaAlbum ? " · " + SystemManager.mediaAlbum : "")
                    color: Theme.text_color
                    font.pixelSize: 10 * scaleFactor
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    opacity: 0.7
                }
            }

            RowLayout {
                spacing: 6 * scaleFactor
                Text {
                    text: formatTime(SystemManager.mediaPositionUs)
                    color: Theme.color_a_text
                    font.pixelSize: 10 * scaleFactor
                    font.family: "monospace"
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 3 * scaleFactor
                    radius: height / 2
                    color: Theme.color_3
                    Rectangle {
                        width: SystemManager.mediaLengthUs > 0
                            ? parent.width * (SystemManager.mediaPositionUs / SystemManager.mediaLengthUs)
                            : 0
                        height: parent.height
                        radius: height / 2
                        color: Theme.color_a_text
                        Behavior on width { NumberAnimation { duration: 300 } }
                    }
                }
                Text {
                    text: formatTime(SystemManager.mediaLengthUs)
                    color: Theme.color_a_text
                    font.pixelSize: 10 * scaleFactor
                }
            }

            RowLayout {
                spacing: 8 * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 26 * scaleFactor

                BasePillSimple {
                    icon: "\uf04a"
                    onClicked: {
                        SystemManager.mediaPrevious()
                        console.log("Previous media track")
                    }
                }
                BasePillSimple {
                    icon: SystemManager.mediaPlaying ? "\uf04c" : "\uf04b"
                    color_text: Theme.color_a_text
                    onClicked: SystemManager.mediaPlayPause()
                }
                BasePillSimple {
                    icon: "\uf04e"
                    onClicked: SystemManager.mediaNext()
                }
            }
        }
    }
}
