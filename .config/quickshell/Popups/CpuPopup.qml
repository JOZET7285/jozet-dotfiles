import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"

Item {
    id: cpuPopup

    property bool open: false
    property bool animating: false

    focus: true
    width: 500
    height: (open || animating) && contentLoader.item ? contentLoader.item.popupHeight : 0
    visible: open || animating

    onOpenChanged: {
        if (open) {
            contentLoader.active = true;
        } else {
            if (contentLoader.item) {
                contentLoader.item.startCloseAnimation();
            }
        }
    }

    IpcHandler {
        target: "cpuPopup"
        function toggle(): void { cpuPopup.open = !cpuPopup.open }
        function show(): void { cpuPopup.open = true }
        function hide(): void { cpuPopup.open = false }
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: ramContent
    }

    Component {
        id: ramContent

        Item {
            id: internalRoot
            anchors.fill: parent

            readonly property int popupHeight: mainLayout.implicitHeight + 40

            Component.onCompleted: {
                container.y = -internalRoot.popupHeight;
                cpuPopup.animating = true;
                openAnim.start();
            }

            function startCloseAnimation() {
                cpuPopup.animating = true;
                closeAnim.start();
            }

            Rectangle {
                id: container
                width: parent.width
                height: internalRoot.popupHeight
                color: Theme.color_1_solid
                radius: 10
                clip: true
                border {
                    color: Theme.color_3_solid
                    width: 1
                }
                ColumnLayout {
                    id: mainLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 20
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            RowLayout {
                                Text {
                                    text: "Global Usage"
                                    color: Theme.text_color
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: sysManager.cpuUsage + "%"
                                    color: Theme.text_color
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 6
                                color: Theme.color_3
                                radius: 3
                                
                                Rectangle {
                                    width: parent.width * (sysManager.cpuUsage / 100)
                                    height: parent.height
                                    color: Theme.color_b
                                    radius: 3
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            spacing: 5
                            Text {
                                text: sysManager.cpuFrequency + " MHz"
                                color: Theme.light_3
                                font.pixelSize: 13
                            }
                        }
                    }   
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: Theme.light_4
                    }
                    Text {
                        text: "Top Processes"
                        color: Theme.light_1
                        font.pixelSize: 13
                        font.bold: true
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5 * 30
                        spacing: 4

                        Repeater {
                            model: (sysManager.topCpuProcesses || []).slice(0, 5)

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 26

                                Text {
                                    text: modelData.name
                                    color: Theme.text_color
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 2
                                    color: Theme.color_3
                                }
                                Text {
                                    text: modelData.usagePercent + "%"
                                    color: Theme.text_color
                                    opacity: 0.6
                                    font.pixelSize: 12
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
                onStopped: { cpuPopup.animating = false; }
            }

            ParallelAnimation {
                id: closeAnim
                PropertyAnimation {
                    target: container
                    property: "y"
                    to: -internalRoot.popupHeight
                    duration: 220
                    easing.type: Easing.InCubic
                }
                onStopped: {
                    cpuPopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
}