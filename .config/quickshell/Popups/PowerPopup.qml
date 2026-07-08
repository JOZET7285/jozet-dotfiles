import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"

Item{
    property bool open: false
    property bool animating: false

    readonly property int contentWidth: 320

    width: parent.width
    height: content.height
    clip: true
    visible: open || animating
    Component.onCompleted: {
        container.y = -content.height
    }
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
    
    IpcHandler {
        target: "powerPopup"

        function toggle(): void {
            powerPopup.open = !powerPopup.open
        }
        function show(): void {
            powerPopup.open = true
        }
        function hide(): void {
            powerPopup.open = false
        }
    }

    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command);
            powerPopup.closeLauncher();
        }
    }
    function closeLauncher() {
        powerPopup.open = false
    }
    Item {
        id: containerWrapper
        anchors.fill: parent
        Rectangle {
            id: container
            anchors.left: parent.left
            anchors.right: parent.right
            height: content.height
            color: "transparent"
            Item {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 190
                
                ColumnLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        margins: 10
                    }
                    spacing: 10

                    Repeater {
                        model: [
                            { label: "Apagar", icon: "\uf011", executable: "/usr/bin/systemctl", args: ["poweroff"], color: "#fca5a5" },
                            { label: "Reiniciar", icon: "\uf021", executable: "/usr/bin/systemctl", args: ["reboot"], color: "#fde68a" },
                            { label: "Suspender", icon: "\uf186", executable: "/usr/bin/systemctl", args: ["suspend"], color: "#93c5fd" },
                            { label: "Bloquear", icon: "\uf023", executable: "/usr/bin/hyprlock", args: [], color: "#a7f3d0"
                            }
                        ]

                        Rectangle {
                            id: buttonRect
                            Layout.fillWidth: true
                            Layout.preferredHeight: 35
                            color: Theme.bg_2
                            radius: 10
                         
                            Rectangle {
                                color: modelData.color
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: mouseArea.pressed ?  parent.width : 10
                                opacity: holdTimer.running ? 1 : 0
                                topRightRadius: 5
                                bottomRightRadius: 5
                                topLeftRadius: mouseArea.pressed ? 5 : 0
                                bottomLeftRadius: mouseArea.pressed ? 5 : 0
                                Behavior on radius {
                                    NumberAnimation { 
                                        duration: 1500
                                        easing.type: Easing.InOutQuad 
                                    }
                                }
                                Behavior on opacity {
                                    NumberAnimation { duration: 300; easing.type: Easing.InOutSine }
                                }
                                Behavior on width {
                                    NumberAnimation { 
                                        duration: 1500
                                        easing.type: Easing.InOutQuad 
                                    }
                                }
                            }
                            Timer {
                                id: holdTimer
                                interval: 1500
                                onTriggered: {
                                    console.log("Triggered", modelData.label)
                                    if (mouseArea.pressed) {
                                        Quickshell.execDetached([
                                            modelData.executable,
                                            ...modelData.args
                                        ])
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                
                                onPressed: {
                                    holdTimer.start()
                                }
                                onReleased: {
                                    holdTimer.stop()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                spacing: 10

                                Text {
                                    text: modelData.icon
                                    font.family: Theme.iconFont
                                    color: mouseArea.pressed ? "#1a1a1a" : "#ccc" 
                                    Behavior on color{ColorAnimation{duration: 1500; easing.type: Easing.InOutQuad}}
                                }
                                Text {
                                    text: modelData.label
                                    font.pixelSize: 13
                                    color: mouseArea.pressed ? "#1a1a1a" : "#ccc"
                                    Behavior on color{ColorAnimation{duration: 1500; easing.type: Easing.InOutQuad}}
                                }
                            }
                        }
                    }
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