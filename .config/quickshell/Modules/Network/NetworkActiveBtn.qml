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

    color: isUp ? Theme.btn_color : Theme.bg_1
    radius: connection.type === "ethernet" ? 25 : 50
    
    border {
        width: 2
        color: isUp ? Theme.accent : Theme.bg_3
    }

    Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    Text {
        text: connection.type === "unknown" ? "\uf127" : connection.type === "ethernet" ? "\uf0e8" : "\uf1eb"
        color: indicatorRoot.isUp ? Theme.bg_2_solid : Theme.text_color
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
        color: Theme.accent
        radius: 1.5

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
                // Se soltó antes de completar 1.5 segundos
                holdTimer.stop();
                progressAnimation.stop();
                progressBar.width = 0;
            }
        }
        
        onExited: {
            if (holdTimer.running) {
                // Se salió del área antes de completar
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
            console.log("Hold timer triggered for", connection.type);
            indicatorRoot.isToggling = true;
            
            if (connection.type === "ethernet") {
                // Toggle ethernet
                console.log("Ethernet status:", indicatorRoot.isUp);
                if (indicatorRoot.isUp) {
                    console.log("Executing: nmcli connection down 'Wired connection 1'");
                    Quickshell.execDetached(["nmcli", "connection", "down", "Wired connection 1"]);
                } else {
                    console.log("Executing: nmcli connection up 'Wired connection 1'");
                    Quickshell.execDetached(["nmcli", "connection", "up", "Wired connection 1"]);
                }
            } else if (connection.type === "wifi") {
                console.log("WiFi status:", indicatorRoot.isUp);
                if (indicatorRoot.isUp) {
                    console.log("Executing: nmcli radio wifi off");
                    Quickshell.execDetached(["nmcli", "radio", "wifi", "off"]);
                } else {
                    console.log("Executing: nmcli radio wifi on");
                    Quickshell.execDetached(["nmcli", "radio", "wifi", "on"]);
                } 
            }
            
            console.log("Status after execution:", connection.status, "Type:", connection.type);
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
