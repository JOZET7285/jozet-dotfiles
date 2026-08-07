import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../Components"
import "../Components/Pills"
import "../Popups"
import Jozet.System 1.0

Rectangle {
    id: container

    property bool active: SystemManager.mediaHasPlayer
    property bool activeHover: active && hoverMediaZone.containsMouse
    property bool openPopup: false

    width: active ? (openPopup || activeHover ? 400 * scaleFactor : 300 * scaleFactor) : 0
    height: openPopup ? 150 : (activeHover ? 30 : 15)

    color: Theme.color_1_solid
    radius: floatingMode ? (roundedCorners ? 10 : 0) : 0
    topLeftRadius: roundedCorners ? (openPopup ? 10 : 30) : 0
    topRightRadius: roundedCorners ? (openPopup ? 10 : 30) : 0
    border.color: shinyEdge && active ? Theme.color_a_text : Theme.color_1
    border.width: 2
    visible: active

    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on width { NumberAnimation { duration: 200 } }
    Behavior on color { ColorAnimation { duration: 250 } }
    Behavior on radius { NumberAnimation { duration: 250 } }
    Behavior on border.color { ColorAnimation { duration: 250 } }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        MediaPopup { 
            id: mediaPopup 
            open: openPopup
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 6 * scaleFactor
            Layout.rightMargin: 12 * scaleFactor
            spacing: 6 * scaleFactor
            visible: !openPopup

            Item {
                Layout.preferredWidth: 30 * scaleFactor
                Layout.preferredHeight: 30 * scaleFactor
                visible: activeHover && !openPopup

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.color_3
                    visible: SystemManager.mediaArtUrl === ""
                    Text {
                        anchors.centerIn: parent
                        text: "\uf001"
                        font.family: Theme.iconFont
                        font.pixelSize: 12 * scaleFactor
                        color: Theme.text_color
                    }
                }

                Image {
                    id: artThumb
                    anchors.fill: parent
                    source: SystemManager.mediaArtUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                }
                MultiEffect {
                    anchors.fill: parent
                    source: artThumb
                    maskEnabled: true
                    maskSource: thumbMask
                }
                Item {
                    id: thumbMask
                    width: parent.width
                    height: parent.height
                    visible: false
                    layer.enabled: true
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Theme.color_1_solid
                    }
                }
            }

            Text {
                text: SystemManager.mediaTitle
                font.pixelSize: (activeHover || openPopup ? 14 : 10) * scaleFactor
                color: Theme.color_a_text
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
            }
        }
    }   
}
