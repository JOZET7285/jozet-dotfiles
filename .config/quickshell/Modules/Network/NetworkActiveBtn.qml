import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../Components"

Rectangle {
    id: indicatorRoot
    Layout.preferredWidth: 95 
    Layout.fillWidth: false
    Layout.fillHeight: true
    
    required property var connection
    property bool isToggling: false

    readonly property bool isUp: connection.status === "up"

    color: isUp ? Theme.color_b : Theme.color_2
    radius: connection.type === "ethernet" ? 25 : 50
    
    border {
        width: 3
        color: isUp ? Theme.color_b_solid : Theme.color_3
    }

    Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    Text {
        text: connection.type === "unknown" ? "\uf127" : connection.type === "ethernet" ? "\uf0e8" : "\uf1eb"
        color: indicatorRoot.isUp ? Theme.color_2 : Theme.light_1
        font.pixelSize: 55
        anchors.centerIn: parent
        opacity: indicatorRoot.isToggling ? 0.5 : 1.0
        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    Rectangle {
        id: progressBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 0
        height: 3
        color: width > 50 ? Theme.color_r : Theme.color_o
        radius: 1.5
        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }}

        PropertyAnimation {
            id: progressAnimation
            target: progressBar
            property: "width"
            from: 0
            to: indicatorRoot.width
            duration: 1500
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onPressed: {
            if (!indicatorRoot.isToggling) {
                holdTimer.start();
                progressAnimation.start();
            }
        }
        
        onReleased: {
            if (holdTimer.running) {
                holdTimer.stop();
                progressAnimation.stop();
                progressBar.width = 0;
            }
        }
        
        onExited: {
            if (holdTimer.running) {
                holdTimer.stop();
                progressAnimation.stop();
                progressBar.width = 0;
            } 
        }
    }
    
    Timer {
        id: holdTimer
        interval: 1500
        onTriggered: {
            indicatorRoot.isToggling = true;
            
            if (connection.type === "ethernet") {
                if (indicatorRoot.isUp) {
                    Quickshell.execDetached(["nmcli", "connection", "down", "Wired connection 1"]);
                } else {
                    Quickshell.execDetached(["nmcli", "connection", "up", "Wired connection 1"]);
                }
            } else if (connection.type === "wifi") {
                if (indicatorRoot.isUp) {
                    Quickshell.execDetached(["nmcli", "radio", "wifi", "off"]);
                } else {
                    Quickshell.execDetached(["nmcli", "radio", "wifi", "on"]);
                } 
            }
            toggleTimeout.start();
        }
    }
    
    Timer {
        id: toggleTimeout
        interval: 1500
        onTriggered: {
            indicatorRoot.isToggling = false;
            progressBar.width = 0;
        }
    }
}
