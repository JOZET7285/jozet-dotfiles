import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"
import "../Modules/Network"

Item {
    id: networkPopup

    property string selectedConnectionType: "auto"
    property var connection: sysManager.ethernetInfo.status !== "down" ? sysManager.ethernetInfo : sysManager.wifiInfo

    onSelectedConnectionTypeChanged: {
        console.log("selectedConnectionType changed to:", selectedConnectionType);
        if (selectedConnectionType === "ethernet") {
            connection = sysManager.ethernetInfo;
            console.log("Set connection to ethernetInfo");
        } else if (selectedConnectionType === "wifi") {
            connection = sysManager.wifiInfo;
            console.log("Set connection to wifiInfo");
        } else {
            connection = sysManager.ethernetInfo.status !== "down" ? sysManager.ethernetInfo : sysManager.wifiInfo;
            console.log("Set connection to auto (active connection)");
        }
    }

    property bool open: false
    property bool animating: false
    readonly property int contentWidth: 320

    width: parent ? parent.width : contentWidth
    height: open || animating ? content.height : 0
    clip: true
    visible: open || animating

    Component.onCompleted: {
        container.y = -content.height
    }

    onOpenChanged: {
        if (open) {
            sysManager.scanNetworks()
            visible = true;
            animating = true;
            openAnim.start();
        } else {
            animating = true;
            closeAnim.start();
        }
    }
    
    IpcHandler {
        target: "networkPopup"

        function toggle(): void {
            networkPopup.open = !networkPopup.open
        }
        function show(): void {
            networkPopup.open = true
        }
        function hide(): void {
            networkPopup.open = false
        }
    }

    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command);
            networkPopup.closeLauncher();
        }
    }
    
    function closeLauncher() {
        networkPopup.open = false
    }

    Rectangle {
        id: container
        width: parent.width
        height: content.height
        color: "transparent"

        Item {
            id: content
            width: parent.width
            height: networkPopup.connection.type === "wifi" ? networkPopup.connection.status === "up" ? 550 : 210 : 210
            
            Behavior on height { 
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } 
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Conexiones"
                    color: Theme.text_color
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 110
                    spacing: 10

                    NetworkActiveBtn { 
                        id: activeNetBtn
                        connection: networkPopup.connection
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 7
                        Layout.preferredHeight: 2
                        color: Theme.bg_1
                        radius: 15
                        
                        NetworkDetails { 
                            id: infoConnection
                            anchors.fill: parent
                            anchors.margins: 10
                            connection: networkPopup.connection
                        }
                    }
                }

                NetworkAvailableList { 
                    id: wifiAvailableNets
                    connection: networkPopup.connection
                }
                
                NetworkTypeToggle {
                    id: typeToggleBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    connection: networkPopup.connection
                    onConnectionTypeChanged: function(type) {
                        console.log("Switching to connection type:", type);
                        networkPopup.selectedConnectionType = type;
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
