import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"
import "../Modules/Volume"

BasePrincipalPopup {
    id: volumePopup
    popupName: "volume"

    property var playbackDevice: SystemManager.playbackDeviceInfo
    property var inputDevice: SystemManager.inputDeviceInfo

    popupContent: Component {
        Item {
            id: content
            width: parent.width
            height: 430
            
            Behavior on height { 
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } 
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Volume"
                    color: Theme.text_color
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 15
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 250
                    spacing: 10

                    OutputDevices { }

                    InputDevices { }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.color_3
                }

                Text {
                    text: "Applications"
                    color: Theme.text_color
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    Layout.leftMargin: 15
                }

                PlayingApps { 
                    opacity: SystemManager.playingApplications.length > 0 ? 1 : 0
                    visible: opacity > 0.5 ? true : false
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
                Text {
                    text: "No applications playing audio"
                    color: Theme.text_color_secondary
                    font.pixelSize: 11
                    font.italic: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    Layout.leftMargin: 15
                    visible: SystemManager.playingApplications.length == 0
                }
            }
        }
    }  
}
