import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"

Item {
    id: ramPopup

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
        target: "ramPopup"
        function toggle(): void { ramPopup.open = !ramPopup.open }
        function show(): void { ramPopup.open = true }
        function hide(): void { ramPopup.open = false }
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
                ramPopup.animating = true;
                openAnim.start();
            }

            function startCloseAnimation() {
                ramPopup.animating = true;
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
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 15

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        spacing: 10
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.color_2
                            radius: 10

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                width: parent.width - 40

                                Text {
                                    text: "RAM"
                                    color: Theme.light_2
                                    font.pixelSize: 12
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: (sysManager.ramInfo.usagePercent || 0) + "%"
                                    color: {
                                        if (sysManager.ramInfo.usagePercent < 25) return Theme.text_color
                                        if (sysManager.ramInfo.usagePercent < 50) return Theme.color_y
                                        if (sysManager.ramInfo.usagePercent < 75) return Theme.color_o
                                        return Theme.color_r
                                    }
                                    font.pixelSize: 22
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    radius: 3
                                    color: Theme.color_3

                                    Rectangle {
                                        height: parent.height
                                        radius: 3
                                        width: parent.width * Math.min(sysManager.ramInfo.usagePercent || 0, 100) / 100
                                        color: {
                                            if (sysManager.ramInfo.usagePercent < 25) return Theme.color_b
                                            if (sysManager.ramInfo.usagePercent < 50) return Theme.color_y
                                            if (sysManager.ramInfo.usagePercent < 75) return Theme.color_o
                                            return Theme.color_r
                                        }
                                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                                    }
                                }

                                Text {
                                    text: (sysManager.ramInfo.usedMB || 0) + " MB / " + (sysManager.ramInfo.totalMB || 0) + " MB"
                                    color: Theme.light_3
                                    font.pixelSize: 10
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 2
                            color: Theme.color_3
                        }

                        // Swap card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.color_2
                            radius: 10

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                width: parent.width - 40

                                Text {
                                    text: "Swap"
                                    color: Theme.light_2
                                    font.pixelSize: 12
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: (sysManager.ramInfo.swapUsagePercent || 0) + "%"
                                    color: {
                                        if (sysManager.ramInfo.swapUsedMB < 25) return Theme.text_color
                                        if (sysManager.ramInfo.swapUsedMB < 50) return Theme.color_y
                                        if (sysManager.ramInfo.swapUsedMB < 75) return Theme.color_o
                                        return Theme.color_r
                                    }
                                    font.pixelSize: 22
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    radius: 3
                                    color: Theme.color_3

                                    Rectangle {
                                        height: parent.height
                                        radius: 3
                                        width: parent.width * Math.min(sysManager.ramInfo.swapUsagePercent || 0, 100) / 100
                                        color: {
                                            if (sysManager.ramInfo.swapUsedMB < 25) return Theme.color_b
                                            if (sysManager.ramInfo.swapUsedMB < 50) return Theme.color_y
                                            if (sysManager.ramInfo.swapUsedMB < 75) return Theme.color_o
                                            return Theme.color_r
                                        }
                                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                                    }
                                }

                                Text {
                                    text: (sysManager.ramInfo.swapUsedMB || 0) + " MB / " + (sysManager.ramInfo.swapTotalMB || 0) + " MB"
                                    color: Theme.light_2
                                    font.pixelSize: 10
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        color: Theme.color_3
                    }

                    Text {
                        text: "Top Processes"
                        color: Theme.text_color
                        font.bold: true
                        font.pixelSize: 13
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5 * 30
                        spacing: 4

                        Repeater {
                            model: (sysManager.topRamProcesses || []).slice(0, 5)

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
                                    text: modelData.memoryMB + " MB"
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
                onStopped: { ramPopup.animating = false; }
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
                    ramPopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
}