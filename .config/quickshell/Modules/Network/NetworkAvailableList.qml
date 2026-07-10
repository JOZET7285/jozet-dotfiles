import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components"

Rectangle {
    id: networkAvailableList
    required property var connection
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    color: Theme.bg_1
    radius: 15

    opacity: connection.type === "wifi" ? connection.status === "up" ? 1.0 : 0.0 : 0.0
    visible: opacity > 0.0
    
    Behavior on opacity { 
        NumberAnimation { duration: 150 } 
    }

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        model: sysManager.availableNetworks.filter(net => !net.connected)
        spacing: 8

        delegate: Item {
            id: delegateRoot
            width: ListView.view.width
            height: networkAvailableContainer.height

            Rectangle {
                id: networkAvailableContainer
                width: parent.width
                height: verifyConnect.visible ? 35 + 35 : 35
                color: maNetworkBtn.containsMouse ? Theme.bg_3 : Theme.bg_2_solid
                radius: 8
                
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }}

                Text {
                    id: infoNetworkAvailable
                    anchors.top: parent.top
                    anchors.topMargin: 10 
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData.ssid + " - " + modelData.signal + "%"
                    color: "white"
                    font.pixelSize: 13
                }
                RowLayout {
                    id: verifyConnect
                    anchors.top: infoNetworkAvailable.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 5
                    visible: false
                    z: 100

                    TextField {
                        id: passwordField
                        color: "#FFFFFF"
                        Layout.fillWidth: false
                        Layout.preferredWidth: 250
                        Layout.fillHeight: true
                        echoMode: TextInput.Password
                        placeholderText: "Contraseña..."
                        placeholderTextColor: "#88889D"
                        font.pixelSize: 12
                        font.family: "Segoe UI", "Roboto", "Helvetica"
                        
                        selectByMouse: true
                        selectedTextColor: "#FFFFFF"
                        selectionColor: Theme.bg_3

                        background: Rectangle {
                            implicitWidth: 280
                            implicitHeight: 30
                            color: passwordField.activeFocus ? Theme.bg_3 : Theme.bg_1
                            radius: 10
                            
                            border.color: {
                                if (passwordField.activeFocus) return '#6d78aa' // Azul si tiene el foco
                                if (passwordField.hovered) return "#4E4E6A"     // Gris claro si el ratón está encima
                                return "transparent"                              // Sin borde por defecto
                            }
                            border.width: 1.5

                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: maConnectNetBtn.containsMouse ? Theme.bg_3 : Theme.bg_1
                        radius: 15
                        MouseArea {
                            id: maConnectNetBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sysManager.connectToNetwork(modelData.ssid, passwordField.text)
                                verifyConnect.visible = false
                            }
                        }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
                
                MouseArea {
                    id: maNetworkBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { verifyConnect.visible = !verifyConnect.visible } 
                }
            }
        }
    }
}
