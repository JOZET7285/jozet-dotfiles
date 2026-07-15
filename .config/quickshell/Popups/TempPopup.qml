import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"

Item {
    id: tempPopup

    property bool open: false
    property bool animating: false

    focus: true
    width: 300
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
        target: "tempPopup"
        function toggle(): void { tempPopup.open = !tempPopup.open }
        function show(): void { tempPopup.open = true }
        function hide(): void { tempPopup.open = false }
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
                tempPopup.animating = true;
                openAnim.start();
            }

            function startCloseAnimation() {
                tempPopup.animating = true;
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
                    Repeater {
                        model: (sysManager.sensorTemperatures || []).slice(0, 5)

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 26

                            Text {
                                text: modelData.name
                                color: {
                                    if (modelData.temperature < 75) return Theme.text_color
                                    if (modelData.temperature < 95) return Theme.color_o
                                    return Theme.color_r
                                }
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }}
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 2
                                color: Theme.color_3
                            }
                            Text {
                                text: modelData.temperature + "°C"
                                color: {
                                    if (modelData.temperature < 75) return Theme.text_color
                                    if (modelData.temperature < 85) return Theme.color_o
                                    return Theme.color_r
                                }
                                opacity: 0.6
                                font.pixelSize: 12
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }}
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
                onStopped: { tempPopup.animating = false; }
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
                    tempPopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
}