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

    width: parent ? parent.width : contentWidth
    height: open || animating ? content.height : 0
    clip: true
    visible: open || animating

    Component.onCompleted: {
        container.y = -content.height
    }

    onOpenChanged: {
        if (open) {
            visible = true;
            animating = true;
            openAnim.start();
        } else {
            animating = true;
            closeAnim.start();
        }
    }
    
    IpcHandler {
        target: "energyPopup"

        function toggle(): void {
            energyPopup.open = !energyPopup.open
        }
        function show(): void {
            energyPopup.open = true
        }
        function hide(): void {
            energyPopup.open = false
        }
    }
    function closePopup() {
        energyPopup.open = false
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
            EnergyModule {
                anchors.fill: parent
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