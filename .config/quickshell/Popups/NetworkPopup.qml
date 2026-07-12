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
        } else if (selectedConnectionType === "wifi") {
            connection = sysManager.wifiInfo;
            sysManager.scanNetworks();
        } else {
            connection = sysManager.ethernetInfo.status !== "down" ? sysManager.ethernetInfo : sysManager.wifiInfo;
        }
    }

    property bool open: false
    property bool animating: false
    readonly property int contentWidth: 320

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
        target: "networkPopup"
        function toggle(): void { networkPopup.open = !networkPopup.open }
        function show(): void { networkPopup.open = true }
        function hide(): void { networkPopup.open = false }
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: networkContent
    }

    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command);
            networkPopup.closeLauncher();
        }
    }
    Component {
        id: networkContent
        Item {
            id: internalRoot
            anchors.fill: parent

            readonly property int popupHeight: content.height

            Component.onCompleted: {
                container.y = -content.height;
                networkPopup.animating = true;
                openAnim.start();
            }
            function startCloseAnimation() {
                networkPopup.animating = true;
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
                                color: Theme.color_2
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
                onStopped: networkPopup.animating = false
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
                    networkPopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
    
}
