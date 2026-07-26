import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: redComponent
    ColumnLayout {
        spacing: 8

        // ── Ethernet ──────────────────────────────────────────
        Text { text: "Ethernet"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Repeater {
            model: ListModel {
                ListElement { label: "Interfaz";  key: "name" }
                ListElement { label: "Estado";    key: "status" }
                ListElement { label: "Velocidad"; key: "speed" }
                ListElement { label: "MAC";       key: "address" }
            }
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: {
                    var v = SystemManager.ethernetInfo[key] || "";
                    return v !== "";
                }
                Text { text: label + ":"; font.pixelSize: 12; color: Theme.color_a_text; Layout.preferredWidth: 90 }
                Text {
                    text: SystemManager.ethernetInfo[key] || ""
                    font.pixelSize: 12
                    color: key === "status" ? Theme.color_g : Theme.text_color
                    Layout.fillWidth: true
                }
            }
        }

        Item { Layout.preferredHeight: 16 }

        // ── WiFi ──────────────────────────────────────────────
        Text { text: "WiFi"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Repeater {
            model: ListModel {
                ListElement { label: "SSID";       key: "ssid" }
                ListElement { label: "Interfaz";   key: "name" }
                ListElement { label: "Estado";     key: "status" }
                ListElement { label: "Señal";      key: "qual" }
                ListElement { label: "Frecuencia"; key: "freq" }
                ListElement { label: "MAC";        key: "address" }
            }
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: {
                    var v = SystemManager.wifiInfo[key];
                    return v !== undefined && v !== "";
                }
                Text { text: label + ":"; font.pixelSize: 12; color: Theme.color_a_text; Layout.preferredWidth: 90 }
                Text {
                    text: {
                        var v = SystemManager.wifiInfo[key];
                        if (v === undefined) return "";
                        if (key === "qual") return v + "%";
                        return v;
                    }
                    font.pixelSize: 12
                    color: key === "status" ? Theme.color_g : Theme.text_color
                    Layout.fillWidth: true
                }
            }
        }

        // ── Redes disponibles ─────────────────────────────────
        Item { Layout.preferredHeight: 12 }
        Text { text: "Redes disponibles"; font.pixelSize: 14; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        ColumnLayout {
            spacing: 2
            Repeater {
                model: SystemManager.availableNetworks
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: "transparent"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10

                        Text {
                            text: "\uf1eb"
                            font.pixelSize: 12
                            color: modelData.connected === true ? Theme.color_g : Theme.text_color
                            opacity: modelData.connected === true ? 1 : 0.5
                        }
                        Text {
                            text: modelData.ssid || ""
                            font.pixelSize: 12
                            color: modelData.connected === true ? Theme.color_g : Theme.text_color
                            Layout.fillWidth: true
                        }
                        Text {
                            text: (modelData.signal || 0) + "%"
                            font.pixelSize: 11
                            color: (modelData.signal || 0) > 60 ? Theme.color_g : (modelData.signal || 0) > 30 ? Theme.color_y : Theme.color_r
                        }
                        Text {
                            text: modelData.security || ""
                            font.pixelSize: 10
                            color: Theme.text_color
                            opacity: 0.5
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
