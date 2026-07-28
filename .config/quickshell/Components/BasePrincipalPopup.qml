// Components/BasePrincipalPopup.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../Components/"

Item {
    id: baseRoot

    signal opened()
    signal closed()

    property bool open: false
    property bool animating: false
    property string popupName: ""
    property string currentMonitor: modelData ? modelData.name : ""
    property Component popupContent: null

    readonly property string ipcTarget: popupName !== "" ? popupName + "Popup-" + currentMonitor : ""

    width: parent ? parent.width : 320
    height: (open || animating) && contentLoader.item ? contentLoader.item.popupHeight : 0
    clip: true
    visible: open || animating

    onOpenChanged: {
        if (open) {
            contentLoader.active = true
        } else if (contentLoader.item) {
            contentLoader.item.startCloseAnimation()
        }
    }

    IpcHandler {
        target: baseRoot.ipcTarget
        enabled: baseRoot.ipcTarget !== ""
        function toggle(): void { baseRoot.open = !baseRoot.open }
        function show(): void { baseRoot.open = true }
        function hide(): void { baseRoot.open = false }
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
            readonly property int popupHeight: loaderForContent.height

            Component.onCompleted: {
                container.y = -internalRoot.popupHeight
                baseRoot.animating = true
                openAnim.start()
            }
            function startCloseAnimation() {
                baseRoot.animating = true
                closeAnim.start()
            }

            Rectangle {
                id: container
                width: parent.width
                height: internalRoot.popupHeight
                color: "transparent"

                Loader {
                    id: loaderForContent
                    width: parent.width
                    sourceComponent: baseRoot.popupContent
                }
            }

            ParallelAnimation {
                id: openAnim
                PropertyAnimation { target: container; property: "y"; to: 0; duration: 220; easing.type: Easing.OutCubic }
                onStopped: { baseRoot.animating = false; baseRoot.opened() }
            }
            ParallelAnimation {
                id: closeAnim
                PropertyAnimation { target: container; property: "y"; to: -internalRoot.popupHeight; duration: 220; easing.type: Easing.InCubic }
                onStopped: {
                    baseRoot.animating = false
                    contentLoader.active = false
                    gc()
                    baseRoot.closed()
                }
            }
        }
    }
}