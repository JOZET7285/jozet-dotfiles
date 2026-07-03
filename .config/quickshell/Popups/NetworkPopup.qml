import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"

Item {
    id: networkPopup

    property bool open: false
    property bool animating: false

    readonly property int contentWidth: 320
    width: parent.width
    height: 570
    clip: true
    visible: open || animating
    onOpenChanged: {
        if (open) {
            Qt.callLater(function() {
                visible = true;
                animating = true;
                openAnim.start();
            })
        } else {
            Qt.callLater(function() {
                animating = true;
                closeAnim.start();
            })
        }
    }
    function closeLauncher() {
        networkPopup.open = false
    }
    IpcHandler {
        target: "networkPopup"

        function toggle(): void {
            networkPopup.open = !networkPopup.open
        }
        function show(): void {
            networkPopup.open = true
        }
        function hide(): void {
            networkPopup.open = false
        }
    }
    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command);
            networkPopup.closeLauncher();
        }
    }
    Item {
        id: containerWrapper
        Rectangle {
            id: container
            width: parent.width
            height: parent.height
            y: -570
            color: Theme.bg_1

            Item {
                id: content
                anchors.fill: parent
                anchors.margins: 10
                RowLayout {
                    id: header
                    anchors { 
                        left: parent.left 
                        top: parent.top 
                    }
                    height: 22
                    Text {
                        text: "Conexiones"
                        color: Theme.text_color
                        font.pixelSize: 15
                        font.bold: true
                    }
                }
                RowLayout {
                    id: infoCurrentConnect
                    anchors{ 
                        left: parent.left 
                        right: parent.right 
                        top: header.bottom 
                    }
                    height: 300
                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                        }
                        height: parent.height
                        color: Theme.bg_1
                        Text {
                            text: {
                                if (netProcesses.netStatus === "Ethernet") return "\uf0e8"
                                if (netProcesses.netStatus === "Wi-Fi") return "\uf1eb"
                                return "\uf127"
                            }
                            font.family: Theme.iconFont  
                            width: 300
                            height: parent.height 
                        }
                    }
                }
            }
        }

    }
    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: container; property: "y"; to: 0; duration: 220; easing.type: Easing.OutCubic }
        onStopped: {
            animating = false
        }
    }

    ParallelAnimation {
        id: closeAnim
        PropertyAnimation { target: container; property: "y"; to: -570; duration: 220; easing.type: Easing.InCubic }
        onStopped: {
            animating = false
            visible = false
        }
    }
}