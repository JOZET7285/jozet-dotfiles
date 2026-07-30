import Jozet.System 1.0
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

        Text { 
            text: "Access Point"
            font.pixelSize: 16
            font.bold: true
            color: Theme.text_color 
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: Theme.color_2
            radius: 5
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            ColumnLayout {
                id: columnInfoAP
                anchors.fill: parent
                spacing: 8
                Repeater {
                    model: ListModel {
                        ListElement { label: "Name";    key: "network_name" }
                        ListElement { label: "Status";    key: "enabled" }
                        ListElement { label: "Security"; key: "security" }
                    }
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 5
                        spacing: 10
                        visible: key !== "network_name" || SystemManager.getSetting("connections.network.access_point.network_name") !== ""
                        Text { 
                            text: label + ":"
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.color_a_text
                            Layout.preferredWidth: 90 
                        }
                        Text {
                            text: {
                                var v = SystemManager.getSetting("connections.network.access_point." + key);
                                if (key === "enabled") return v === true ? "Enabled" : "Disabled";
                                else if (key === "security") return v === true ? "Enabled" : "Disabled";
                                return v || "";
                            }
                            font.pixelSize: 12
                            color: {
                                var v = SystemManager.getSetting("connections.network.access_point." + key);
                                if (key === "enabled") return v === true ? Theme.color_g : Theme.color_r;
                                return Theme.text_color;
                            }
                            Layout.fillWidth: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: SystemManager.getSetting("connections.network.access_point.enabled") === true
                            && SystemManager.wifiInfo.status !== "up"
                    Text { text: "Interfaz:"; font.pixelSize: 12; color: Theme.color_a_text; Layout.preferredWidth: 90 }
                    Text {
                        text: SystemManager.getSetting("connections.network.access_point.interface") || "No configurada"
                        font.pixelSize: 12
                        color: SystemManager.getSetting("connections.network.access_point.interface") ? Theme.color_g : Theme.color_y
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 8 }

        Process {
            id: apProcess
            onExited: (exitCode, exitStatus) => {
                if (exitCode !== 0) {
                    SystemManager.setSetting("connections.network.access_point.enabled", false);
                }
            }
        }

        Timer {
            id: apStatusTimer
            interval: 5000
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                apCheck.running = false;
                apCheck.command = ["sh", "-c", "nmcli -t -f TYPE,NAME,DEVICE connection show --active 2>/dev/null | grep -q '^wifi:Jozet-AP:' && echo up || echo down"];
                apCheck.running = true
            }
        }

        Process {
            id: apCheck
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return;
                    var active = data.trim() === "up";
                    var stored = SystemManager.getSetting("connections.network.access_point.enabled") === true;
                    if (active !== stored) {
                        SystemManager.setSetting("connections.network.access_point.enabled", active);
                    }
                }
            }
        }

        function startAP() {
            var iface = SystemManager.getSetting("connections.network.access_point.interface") || "wlo1";
            var ssid = SystemManager.getSetting("connections.network.access_point.network_name") || "Jozet-AP";
            var psk = SystemManager.getSetting("connections.network.access_point.password") || "";
            var secure = SystemManager.getSetting("connections.network.access_point.security") === true;
            apProcess.running = false;
            apProcess.command = ["sh", "-c",
                "if ! nmcli connection show Jozet-AP &>/dev/null; then " +
                "nmcli connection add type wifi ifname '" + iface + "' mode ap con-name Jozet-AP ssid '" + ssid + "'; " +
                "fi; " +
                "nmcli connection modify Jozet-AP 802-11-wireless.ssid '" + ssid + "'; " +
                "nmcli connection modify Jozet-AP ipv4.method shared ipv6.method disabled; " +
                (secure && psk ?
                    "nmcli connection modify Jozet-AP 802-11-wireless-security.key-mgmt wpa-psk " +
                    "802-11-wireless-security.psk '" + psk + "'; " :
                    "nmcli connection modify Jozet-AP 802-11-wireless-security.key-mgmt '' 802-11-wireless-security.psk ''; ") +
                "nmcli connection down Jozet-AP &>/dev/null; " +
                "nmcli device disconnect '" + iface + "' &>/dev/null; " +
                "nmcli connection up Jozet-AP ifname '" + iface + "'"
            ];
            apProcess.running = true;
        }

        function stopAP() {
            apProcess.running = false;
            apProcess.command = ["nmcli", "connection", "down", "Jozet-AP"];
            apProcess.running = true;
        }

        Text {
            Layout.leftMargin: 15
            text: "Settings"
            font.pixelSize: 14
            font.bold: true
            color: Theme.color_a_text
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true 

            color: Theme.color_2
            radius: 5
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text { 
                        text: "Enabled:" 
                        font.pixelSize: 12 
                        font.bold: true 
                        color: Theme.color_a_text 
                        Layout.preferredWidth: 90 
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        Layout.preferredWidth: 40 
                        Layout.preferredHeight: 22
                        radius: 11
                        color: Theme.color_1
                        Rectangle {
                            id: enabledApIndicator
                            width: 18 
                            height: 18 
                            radius: 9 
                            color: {
                                var en = SystemManager.getSetting("connections.network.access_point.enabled") === true;
                                return en ? Theme.color_a_text : Theme.color_3;
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            x: SystemManager.getSetting("connections.network.access_point.enabled") === true ? 20 : 2
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var current = SystemManager.getSetting("connections.network.access_point.enabled") === true;
                                SystemManager.setSetting("connections.network.access_point.enabled", !current);
                                if (!current) {
                                    startAP();
                                    enabledApIndicator.x = 20
                                    enabledApIndicator.color = Theme.color_a_text
                                }
                                else {
                                    stopAP();
                                    enabledApIndicator.x = 2
                                    enabledApIndicator.color = Theme.color_3
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: apProcess.running
                    Text {
                        text: "Starting AP…"
                        font.pixelSize: 12 
                        font.bold: true
                        color: Theme.color_y 
                        Layout.preferredWidth: 90
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text { 
                        text: "Interface:"
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                        Layout.preferredWidth: 90 
                    }

                    Process {
                        id: ifaceLister
                        command: ["sh", "-c", "for f in /sys/class/net/*; do [ -e \"$f/device\" ] && basename \"$f\"; done"]
                        stdout: SplitParser {
                            onRead: data => {
                                if (!data) return
                                var lines = data.trim().split('\n')
                                var current = SystemManager.getSetting("connections.network.access_point.interface") || ""
                                var items = []
                                for (var i = 0; i < lines.length; i++) {
                                    var iface = lines[i].trim()
                                    if (iface) items.push(iface)
                                }
                                ifaceCombo.model = items
                                if (current && items.indexOf(current) >= 0)
                                    ifaceCombo.currentIndex = items.indexOf(current)
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 26 
                        Layout.preferredHeight: 26 
                        radius: 6
                        color: refreshIfaceBtn.containsMouse ? Theme.color_3 : Theme.color_1_solid
                        Text { anchors.centerIn: parent; text: "\uf021"; font.pixelSize: 11; color: Theme.text_color }
                        MouseArea {
                            id: refreshIfaceBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { ifaceLister.running = false; ifaceLister.running = true }
                        }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    ComboBox {
                        id: ifaceCombo
                        Layout.fillWidth: true; Layout.preferredHeight: 28
                        editable: true
                        model: []
                        Component.onCompleted: ifaceLister.running = true

                        onActivated: SystemManager.setSetting("connections.network.access_point.interface", currentText)
                        onAccepted: SystemManager.setSetting("connections.network.access_point.interface", currentText)

                        delegate: ItemDelegate {
                            width: ifaceCombo.width; height: 28
                            text: modelData || ""
                            font.pixelSize: 12
                            contentItem: Text { text: modelData || ""; font.pixelSize: 12; color: Theme.text_color; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
                            background: Rectangle { color: highlighted ? Theme.color_3 : Theme.color_1_solid; radius: 6 }
                        }

                        contentItem: Text {
                            text: ifaceCombo.displayText
                            font.pixelSize: 12; color: Theme.text_color; verticalAlignment: Text.AlignVCenter; leftPadding: 8
                        }

                        background: Rectangle {
                            color: Theme.color_1_solid; radius: 6
                            border.color: Theme.color_3; border.width: 1
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text { 
                        text: "Name:" 
                        font.pixelSize: 12 
                        font.bold: true
                        color: Theme.color_a_text 
                        Layout.preferredWidth: 90
                    }
                    Rectangle {
                        Layout.fillWidth: true 
                        Layout.preferredHeight: 28 
                        radius: 6 
                        color: Theme.color_2
                        border.color: Theme.color_3; border.width: 1
                        TextInput {
                            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12; color: Theme.text_color
                            text: SystemManager.getSetting("connections.network.access_point.network_name") || ""
                            onTextChanged: SystemManager.setSetting("connections.network.access_point.network_name", text)
                            clip: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text { 
                        text: "Password:"
                        font.pixelSize: 12 
                        font.bold: true
                        color: Theme.color_a_text 
                        Layout.preferredWidth: 90 
                    }
                    Rectangle {
                        Layout.fillWidth: true 
                        Layout.preferredHeight: 28 
                        radius: 6
                        color: Theme.color_2
                        border.color: Theme.color_3; border.width: 1
                        TextInput {
                            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12; color: Theme.text_color
                            echoMode: TextInput.Password
                            text: SystemManager.getSetting("connections.network.access_point.password") || ""
                            onTextChanged: SystemManager.setSetting("connections.network.access_point.password", text)
                            clip: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text { 
                        text: "Security:" 
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                        Layout.preferredWidth: 90 }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        Layout.preferredWidth: 40 
                        Layout.preferredHeight: 22 
                        radius: 11
                        color: Theme.color_1 
                        Rectangle {
                            id: securityToggle
                            width: 18
                            height: 18
                            radius: 9
                            color: SystemManager.getSetting("connections.network.access_point.security") === true ? Theme.color_a_text : Theme.color_3
                            anchors.verticalCenter: parent.verticalCenter
                            x: SystemManager.getSetting("connections.network.access_point.security") === true ? 20 : 2
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var current = SystemManager.getSetting("connections.network.access_point.security") === true;
                                SystemManager.setSetting("connections.network.access_point.security", !current);
                                if(!current){
                                    securityToggle.x = 20
                                    securityToggle.color = Theme.color_a_text
                                }else {
                                    securityToggle.x = 2
                                    securityToggle.color = Theme.color_3
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
