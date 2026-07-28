import Jozet.System 1.0
import QtQuick
import QtQuick.Layouts
import "../Components/"
import "../Modules/Network"

BasePrincipalPopup {
    id: networkPopup
    popupName: "network"

    property string selectedConnectionType: "auto"
    property var connection: SystemManager.ethernetInfo.status == "up" ? SystemManager.ethernetInfo : SystemManager.wifiInfo

    onSelectedConnectionTypeChanged: {
        if (selectedConnectionType === "ethernet") connection = SystemManager.ethernetInfo
        else if (selectedConnectionType === "wifi") { connection = SystemManager.wifiInfo; SystemManager.scanNetworks() }
        else connection = SystemManager.ethernetInfo.status == "up" ? SystemManager.ethernetInfo : SystemManager.wifiInfo
    }

    popupContent: Component {
        Item {
            width: networkPopup.width
            height: networkPopup.connection.type === "wifi" ? (networkPopup.connection.status === "up" ? 550 : 220) : 220
            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Network Connections"
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
                        networkPopup.selectedConnectionType = type;
                    }
                }
            }
        }
    }
}