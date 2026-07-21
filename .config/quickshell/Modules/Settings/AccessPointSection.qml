import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: accessPointSection
    ColumnLayout {
        spacing: 8

        Text { text: "Access Point"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        // Status from settings
        Repeater {
            model: ListModel {
                ListElement { label: "Nombre";    key: "network_name" }
                ListElement { label: "Estado";    key: "enabled" }
                ListElement { label: "Seguridad"; key: "security" }
            }
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: key !== "network_name" || sysManager.getSetting("connections.network.access_point.network_name") !== ""
                Text { text: label + ":"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 90 }
                Text {
                    text: {
                        var v = sysManager.getSetting("connections.network.access_point." + key);
                        if (key === "enabled") return v === true ? "Activo" : "Inactivo";
                        if (key === "security") return v === true ? "Activado" : "Desactivado";
                        return v || "";
                    }
                    font.pixelSize: 12
                    color: {
                        var v = sysManager.getSetting("connections.network.access_point." + key);
                        if (key === "enabled") return v === true ? Theme.color_g : Theme.color_r;
                        return Theme.text_color;
                    }
                    Layout.fillWidth: true
                }
            }
        }

        // Hotspot interface — show when AP is active, WiFi is inactive
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: sysManager.getSetting("connections.network.access_point.enabled") === true
                    && sysManager.wifiInfo.status !== "up"
            Text { text: "Interfaz:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 90 }
            Text {
                text: sysManager.getSetting("connections.network.access_point.interface") || "No configurada"
                font.pixelSize: 12
                color: sysManager.getSetting("connections.network.access_point.interface") ? Theme.color_g : Theme.color_y
                Layout.fillWidth: true
            }
        }

        Item { Layout.preferredHeight: 8 }

        // Toggle AP
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Activar AP:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 90 }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 40; height: 22; radius: 11
                color: sysManager.getSetting("connections.network.access_point.enabled") === true ? Theme.color_g : Theme.color_3
                Rectangle {
                    width: 18; height: 18; radius: 9; color: Theme.text_color
                    anchors.verticalCenter: parent.verticalCenter
                    x: sysManager.getSetting("connections.network.access_point.enabled") === true ? 20 : 2
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var current = sysManager.getSetting("connections.network.access_point.enabled") === true;
                        sysManager.setSetting("connections.network.access_point.enabled", !current);
                    }
                }
            }
        }

        // Interface
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Interfaz:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 90 }
            Rectangle {
                Layout.fillWidth: true; height: 28; radius: 6; color: Theme.color_2
                border.color: Theme.color_3; border.width: 1
                TextInput {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12; color: Theme.text_color
                    text: sysManager.getSetting("connections.network.access_point.interface") || ""
                    onTextChanged: sysManager.setSetting("connections.network.access_point.interface", text)
                    clip: true
                }
            }
        }

        // Network name
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Nombre:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 90 }
            Rectangle {
                Layout.fillWidth: true; height: 28; radius: 6; color: Theme.color_2
                border.color: Theme.color_3; border.width: 1
                TextInput {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12; color: Theme.text_color
                    text: sysManager.getSetting("connections.network.access_point.network_name") || ""
                    onTextChanged: sysManager.setSetting("connections.network.access_point.network_name", text)
                    clip: true
                }
            }
        }

        // Password
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Contraseña:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 90 }
            Rectangle {
                Layout.fillWidth: true; height: 28; radius: 6; color: Theme.color_2
                border.color: Theme.color_3; border.width: 1
                TextInput {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12; color: Theme.text_color
                    echoMode: TextInput.Password
                    text: sysManager.getSetting("connections.network.access_point.password") || ""
                    onTextChanged: sysManager.setSetting("connections.network.access_point.password", text)
                    clip: true
                }
            }
        }

        // Security toggle
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Seguridad:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 90 }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 40; height: 22; radius: 11
                color: sysManager.getSetting("connections.network.access_point.security") === true ? Theme.color_g : Theme.color_3
                Rectangle {
                    width: 18; height: 18; radius: 9; color: Theme.text_color
                    anchors.verticalCenter: parent.verticalCenter
                    x: sysManager.getSetting("connections.network.access_point.security") === true ? 20 : 2
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var current = sysManager.getSetting("connections.network.access_point.security") === true;
                        sysManager.setSetting("connections.network.access_point.security", !current);
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
