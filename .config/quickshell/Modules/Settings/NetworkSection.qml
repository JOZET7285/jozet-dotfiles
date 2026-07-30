import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: redComponent
    ScrollView {
        id: scrollView
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            spacing: 8
            width: scrollView.availableWidth

            Text { text: "Ethernet"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
            Rectangle {
                id: ethCard
                Layout.fillWidth: true
                Layout.leftMargin: 15; Layout.rightMargin: 15
                color: Theme.color_2; radius: 5; clip: true
                implicitHeight: ethCol.height + 16
                ColumnLayout {
                    id: ethCol
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 12; spacing: 10
                    Repeater {
                        model: ListModel {
                            ListElement { label: "Interface";  key: "name" }
                            ListElement { label: "Status";    key: "status" }
                            ListElement { label: "Speed"; key: "speed" }
                            ListElement { label: "MAC";       key: "address" }
                        }
                        delegate: RowLayout {
                            Layout.fillWidth: true; spacing: 10
                            visible: {
                                var v = SystemManager.ethernetInfo[key] || "";
                                return v !== "";
                            }
                            Text { 
                                text: label + ":"
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.color_a_text
                                Layout.preferredWidth: 90 
                            }
                            Text {
                                text: SystemManager.ethernetInfo[key] || ""
                                font.pixelSize: 12 
                                color: key === "status" ? Theme.color_g : Theme.text_color
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 12 }

            Text { text: "WiFi"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
            Rectangle {
                id: wifiCard
                Layout.fillWidth: true
                Layout.leftMargin: 15; Layout.rightMargin: 15
                color: Theme.color_2; radius: 5; clip: true
                implicitHeight: wifiCol.height + 24
                ColumnLayout {
                    id: wifiCol
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 12; spacing: 10
                    Repeater {
                        model: ListModel {
                            ListElement { label: "SSID";       key: "ssid" }
                            ListElement { label: "Interface";   key: "name" }
                            ListElement { label: "Status";     key: "status" }
                            ListElement { label: "Signal";      key: "qual" }
                            ListElement { label: "Frequency"; key: "freq" }
                            ListElement { label: "MAC";        key: "address" }
                        }
                        delegate: RowLayout {
                            Layout.fillWidth: true; spacing: 10
                            visible: {
                                var v = SystemManager.wifiInfo[key];
                                return v !== undefined && v !== "";
                            }
                            Text { 
                                text: label + ":"
                                font.pixelSize: 12
                                color: Theme.color_a_text 
                                Layout.preferredWidth: 90 
                                font.bold: true
                            }
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
                }
            }

            Item { Layout.preferredHeight: 12 }
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Available Networks"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
                Rectangle {
                    Layout.preferredWidth: 26; Layout.preferredHeight: 26; radius: 13
                    color: scanNetBtn.containsMouse ? Theme.color_3 : Theme.color_1_solid
                    Text { anchors.centerIn: parent; text: "\uf021"; font.pixelSize: 11; color: Theme.text_color }
                    MouseArea {
                        id: scanNetBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: SystemManager.scanNetworks()
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
            Rectangle {
                id: netCard
                Layout.fillWidth: true
                Layout.leftMargin: 15; Layout.rightMargin: 15
                color: Theme.color_2; radius: 5; clip: true
                implicitHeight: netCol.height + 16
                ColumnLayout {
                    id: netCol
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 10; spacing: 6
                    Repeater {
                    model: {
                        if (!SystemManager.availableNetworks) return [];
                        let rawArray = Array.from(SystemManager.availableNetworks);
                        return rawArray.sort((a, b) => b.signal - a.signal);
                    }
                    delegate: Rectangle {
                        id: delegateRoot
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        Layout.rightMargin: 15
                        implicitHeight: column.implicitHeight + 16
                        color: showPassword ? Theme.color_2 : "transparent"
                        radius: 6
                        clip: true

                        property bool showPassword: false

                        Behavior on color { ColorAnimation { duration: 150 } }

                        MouseArea {
                            id: clickArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!modelData.connected) {
                                    if (modelData.saved) {
                                        SystemManager.connectToNetwork(modelData.ssid, '', true)
                                        SystemManager.scanNetworks()
                                    } else {
                                        showPassword = !showPassword
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            id: column
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            spacing: 5

                            RowLayout {
                                id: topRow
                                Layout.fillWidth: true
                                height: 28
                                spacing: 8

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
                                    elide: Text.ElideRight
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

                                Rectangle {
                                    id: forgetBtn
                                    Layout.preferredWidth: 20; Layout.preferredHeight: 20; radius: 4
                                    visible: modelData.saved === true
                                    color: forgetBtnArea.containsMouse ? Theme.color_r : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "\uf1f8"
                                        font.pixelSize: 10
                                        color: forgetBtnArea.containsMouse ? Theme.text_color : Theme.color_r
                                    }
                                    MouseArea {
                                        id: forgetBtnArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: settingsPopup.forgetNetwork(modelData.ssid)
                                    }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }

                            RowLayout {
                                id: bottomRow
                                Layout.fillWidth: true
                                visible: showPassword
                                spacing: 6

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 26
                                    radius: 6
                                    color: passwordField.activeFocus ? Theme.color_3 : Theme.color_1_solid
                                    border.color: passwordField.activeFocus ? Theme.color_b : "transparent"
                                    border.width: 1

                                    TextInput {
                                        id: passwordField
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 11
                                        color: Theme.text_color
                                        echoMode: TextInput.Password
                                        clip: true
                                        selectByMouse: true
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 60; Layout.preferredHeight: 26; radius: 6
                                    color: connectBtn.containsMouse ? Theme.color_g : Theme.color_3
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Conectar"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: connectBtn.containsMouse ? Theme.text_color : Theme.color_g
                                    }
                                    MouseArea {
                                        id: connectBtn
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            SystemManager.connectToNetwork(modelData.ssid, passwordField.text, modelData.saved)
                                            SystemManager.scanNetworks()
                                            showPassword = false
                                        }
                                    }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
}
