import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"

Item {
    id: basePopupRoot

    property bool open: false
    property bool animating: false
    property int customWidth: 300
    property string ipcTarget: ""
    
    property Component popupContent: null

    focus: true
    width: customWidth
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
        target: basePopupRoot.ipcTarget
        function toggle(): void { basePopupRoot.open = !basePopupRoot.open }
        function show(): void { basePopupRoot.open = true }
        function hide(): void { basePopupRoot.open = false }
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: wrapperComponent
    }

    Component {
        id: wrapperComponent

        Item {
            id: internalRoot
            anchors.fill: parent

            readonly property int popupHeight: loaderForContent.implicitHeight + 40

            Component.onCompleted: {
                container.y = -internalRoot.popupHeight;
                basePopupRoot.animating = true;
                openAnim.start();
            }

            function startCloseAnimation() {
                basePopupRoot.animating = true;
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
                
                Loader {
                    id: loaderForContent
                    anchors.fill: parent
                    anchors.margins: 10
                    sourceComponent: basePopupRoot.popupContent
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
                onStopped: { basePopupRoot.animating = false; }
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
                    basePopupRoot.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
}