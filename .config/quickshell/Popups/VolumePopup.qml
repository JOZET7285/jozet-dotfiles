import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"
import "../Modules/Volume"

Item {
    id: volumePopup

    property bool open: false
    property bool animating: false
    readonly property int contentWidth: 420

    property var playbackDevice: sysManager.playbackDeviceInfo
    property var inputDevice: sysManager.inputDeviceInfo

    width: parent ? parent.width : contentWidth
    height: open || animating ? content.height : 0
    clip: true
    visible: open || animating

    Component.onCompleted: {
        container.y = -content.height
    }

    onOpenChanged: {
        if (open) {
            visible = true;
            animating = true;
            openAnim.start();
        } else {
            animating = true;
            closeAnim.start();
        }
    }
    
    IpcHandler {
        target: "volumePopup"

        function toggle(): void {
            volumePopup.open = !volumePopup.open
        }
        function show(): void {
            volumePopup.open = true
        }
        function hide(): void {
            volumePopup.open = false
        }
    }

    function closePopup() {
        volumePopup.open = false
    }

    Rectangle {
        id: container
        width: parent.width
        height: content.height
        color: "transparent"

        Item {
            id: content
            width: parent.width
            height: 450
            
            Behavior on height { 
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } 
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Volumen"
                    color: Theme.text_color
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
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
                    color: Theme.bg_3
                }

                Text {
                    text: "Aplicaciones"
                    color: Theme.text_color
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                }

                PlayingApps { 
                    opacity: sysManager.playingApplications.length > 0 ? 1 : 0
                    visible: opacity > 0.5 ? true : false
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
                Text {
                    text: "No hay aplicaciones reproduciendo audio"
                    color: "grey"
                    font.pixelSize: 11
                    font.italic: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    visible: sysManager.playingApplications.length == 0
                }
            }
        }
    }

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { 
            target: container
            property: "y"
            to: 0
            duration: 220
            easing.type: Easing.OutCubic 
        }
        onStopped: {
            animating = false
        }
    }

    ParallelAnimation {
        id: closeAnim
        PropertyAnimation { 
            target: container
            property: "y"
            to: -content.height 
            duration: 220
            easing.type: Easing.InCubic 
        }
        onStopped: {
            animating = false
            visible = false
        }
    }
}
