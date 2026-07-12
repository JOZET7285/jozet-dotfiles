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
    height: (open || animating) && contentLoader.item ? contentLoader.item.popupHeight : 0    
    clip: true
    visible: open || animating
    onOpenChanged: {
        if (open) {
            Qt.callLater(function() {
                contentLoader.active = true;
            })
        } else {
            Qt.callLater(function () {
                contentLoader.item.startCloseAnimation();
            })
        }
    }
    
    IpcHandler {
        target: "volumePopup"
        function toggle(): void { volumePopup.open = !volumePopup.open }
        function show(): void { volumePopup.open = true }
        function hide(): void { volumePopup.open = false }
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: volumeContent
    }
    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command);
            volumePopup.closeLauncher();
        }
    }
    Component {
        id: volumeContent
        Item {
            id: internalRoot
            anchors.fill: parent

            readonly property int popupHeight: content.height

            Component.onCompleted: {
                container.y = -content.height;
                volumePopup.animating = true;
                openAnim.start();
            }
            function startCloseAnimation() {
                volumePopup.animating = true;
                closeAnim.start();
            }
            Rectangle {
                id: container
                width: parent.width
                height: content.height
                color: "transparent"

                Item {
                    id: content
                    width: parent.width
                    height: 390
                    
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
                            color: Theme.color_3
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
                            color: Theme.light_4
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
                onStopped: volumePopup.animating = false
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
                    volumePopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
    
}
