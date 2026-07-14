import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"
import "../Modules/Disk"

Item {
    id: diskPopup

    property bool open: false
    property bool animating: false

    focus: true
    width: 800
    height: (open || animating) && contentLoader.item ? contentLoader.item.popupHeight : 0
    visible: open || animating
    
    onOpenChanged: {
        if (open) { 
            contentLoader.active = true;
            sysManager.refreshDiskStats();
        } else {
            if(contentLoader.item){
                contentLoader.item.startCloseAnimation();
            }
        }
    }

    IpcHandler {
        target: "diskPopup"
        function toggle(): void { diskPopup.open = !diskPopup.open }
        function show(): void { diskPopup.open = true }
        function hide(): void { diskPopup.open = false }
    }
    
    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: diskContent
    }

    Component {
        id: diskContent

        Item {
            id: internalRoot
            anchors.fill: parent

            readonly property int popupHeight: mainLayout.implicitHeight + 40

            Component.onCompleted: {
                container.y = -internalRoot.popupHeight;
                diskPopup.animating = true;
                openAnim.start();
            }

            function startCloseAnimation() {
                diskPopup.animating = true;
                closeAnim.start();
            }

            Rectangle {
                id: container
                width: parent.width
                height: internalRoot.popupHeight
                color: Theme.color_1_solid
                radius: 10
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
                        Layout.preferredHeight: 300
                        spacing: 10

                        FoldersUsage {
                            id: foldersUsageArea
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 2
                            color: Theme.color_3
                        }
                        PartitionsUsage {
                            id: partitionsUsageArea
                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        color: Theme.color_3
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        spacing: 10
                        HealthDisk {
                            id: healthDiskArea
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 2
                            color: Theme.color_3
                        }
                        MaintenanceInfo {
                            id: maintenanceInfoArea
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
                    diskPopup.animating = false; 
                }
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
                    diskPopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
}
