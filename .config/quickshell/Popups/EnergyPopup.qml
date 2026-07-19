import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"
import "../Modules/Energy"

Item {
    id: energyPopup

    property bool open: false
    property bool animating: false
    readonly property int contentWidth: 420
    property string currentMonitor: modelData.name

    width: parent ? parent.width : contentWidth
    height: (open || animating) && contentLoader.item ? contentLoader.item.popupHeight : 0    
    clip: true
    visible: open || animating

    onOpenChanged: {
        if (open) {
            contentLoader.active = true;
        } else {
            if(contentLoader.item){
                contentLoader.item.startCloseAnimation();
            }
        }
    }
    
    IpcHandler {
        target: "energyPopup-"+currentMonitor
        function toggle(): void { energyPopup.open = !energyPopup.open }
        function show(): void { energyPopup.open = true }
        function hide(): void { energyPopup.open = false }
    }
    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: energyContent
    }
    Component {
        id: energyContent
        Item {
            id: internalRoot
            anchors.fill: parent

            readonly property int popupHeight: content.height

            Component.onCompleted: {
                container.y = -content.height;
                energyPopup.animating = true;
                openAnim.start();
            }
            function startCloseAnimation() {
                energyPopup.animating = true;
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
                    height: 200
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        EnergyModule {
                        }
                        BrightnessModule {
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
                onStopped: energyPopup.animating = false;
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
                    energyPopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }    
}