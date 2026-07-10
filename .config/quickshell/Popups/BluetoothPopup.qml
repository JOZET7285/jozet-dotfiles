import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components/"
import "../Modules/Network"

Item {
    property bool open: false
    property bool animating: false
    property string connectingAddress: ""
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
            visible = true;
            animating = true;
            openAnim.start();
        } else {
            animating = true;
            closeAnim.start();
        }
    }

    IpcHandler {
        target: "bluetoothPopup"
        function toggle(): void { bluetoothPopup.open = !bluetoothPopup.open }
        function show(): void { bluetoothPopup.open = true }
        function hide(): void { bluetoothPopup.open = false }
    }

    Rectangle {
        id: container
        width: parent.width
        height: content.height
        color: "transparent"

        Item {
            id: content
            width: parent.width
            height: Math.min(
                Math.max(150, calculateHeight()),
                550
            )
            
            function calculateHeight() {
                let h = 30; // márgenes
                h += 25; // label conectados
                h += 10; // spacing
                
                // dispositivos conectados
                let connectedCount = sysManager.availableBluetoothDevices.filter(d => d.connected).length;
                h += connectedCount > 0 ? (connectedCount * 50 + (connectedCount - 1) * 8) : 25;
                
                h += 10; // spacing
                h += 1;  // divisor
                h += 10; // spacing
                h += 25; // label disponibles
                h += 10; // spacing
                
                // grid disponibles
                let availableCount = Math.min(sysManager.availableBluetoothDevices.filter(d => !d.connected).length, 9);
                let gridRows = Math.ceil(availableCount / 3);
                h += gridRows > 0 ? (gridRows * 50 + (gridRows - 1) * 10) : 0;
                
                return h;
            }
            
            Behavior on height { 
                NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } 
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                clip: true

                Label {
                    text: "Conectados"
                    color: Theme.text_color
                    font.bold: true
                    font.pointSize: 11
                }

                ColumnLayout {
                    id: connectedRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    spacing: 8
                    clip: true

                    readonly property var connectedList: sysManager.availableBluetoothDevices.filter(d => d.connected)
                    readonly property int count: connectedList.length
                    property real contentHeight: count > 0 ? (count * 50 + (count - 1) * 8) : 25

                    Text {
                        visible: connectedRow.count === 0
                        text: "Sin conexión"
                        color: Theme.light_4
                        font.italic: true
                        Layout.fillWidth: true
                    }

                    Repeater {
                        id: connectedDevices
                        model: connectedRow.connectedList

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.color_3
                            radius: 8
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: Theme.color_b
                                }

                                Column {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.name || "Dispositivo"
                                        color: Theme.text_color
                                        font.bold: true
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        text: modelData.address
                                        color: Theme.light_4
                                        font.pixelSize: 9
                                    }
                                }

                                Button {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    text: "✕"
                                    contentItem: Text {
                                        text: parent.text
                                        color: Theme.text_color
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.hovered ? Theme.color_r_solid : Theme.color_3_solid
                                        radius: 4
                                        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                    }
                                    onClicked: {
                                        sysManager.disconnectBluetooth(modelData.address)
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.color_3_solid
                }

                Label {
                    text: "Disponibles"
                    color: Theme.text_color
                    font.bold: true
                    font.pointSize: 11
                }

                GridLayout {
                    id: gridContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(gridRows * 60 + (gridRows - 1) * 10, 200)
                    Layout.maximumHeight: 200

                    columns: 3
                    columnSpacing: 10
                    rowSpacing: 10
                    clip: true

                    readonly property var availableList: sysManager.availableBluetoothDevices.filter(d => !d.connected)
                    readonly property int count: Math.min(availableList.length, 9)
                    readonly property int gridRows: Math.ceil(count / 3)

                    Repeater {
                        model: gridContainer.count

                        delegate: Button {
                            property var device: gridContainer.availableList[index]
                            property bool isConnecting: bluetoothPopup.connectingAddress === device.address

                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            Layout.minimumWidth: 80
                            enabled: !isConnecting && bluetoothPopup.connectingAddress === ""

                            contentItem: Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: isConnecting ? "Conectando..." : (device.name || "Desconocido")
                                    color: Theme.text_color
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    width: parent.width
                                    elide: Text.ElideRight
                                    font.pointSize: 9
                                }

                                BusyIndicator {
                                    visible: isConnecting
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 20
                                    height: 20
                                }
                            }

                            background: Rectangle {
                                color: isConnecting ? Theme.color_b : 
                                       (parent.down ? Theme.color_2 : 
                                       (parent.hovered ? Theme.color_3 : Theme.color_1_solid))
                                border.color: isConnecting ? Theme.color_b : Theme.light_3
                                border.width: isConnecting ? 2 : 1
                                radius: 10
                                opacity: enabled ? 1.0 : 0.5
                            }

                            onClicked: {
                                if (!isConnecting) {
                                    bluetoothPopup.connectingAddress = device.address
                                    sysManager.connectBluetooth(device.address)
                                    connectionTimeout.start()
                                }
                            }
                        }
                    }

                    Text {
                        visible: gridContainer.count === 0
                        text: "No hay dispositivos disponibles"
                        color: Theme.light_4
                        font.italic: true
                        Layout.columnSpan: 3
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    Connections {
        target: sysManager
        function onBluetoothChanged() {
            connectionTimeout.stop()
            bluetoothPopup.connectingAddress = ""
        }
    }

    Timer {
        id: connectionTimeout
        interval: 5000
        onTriggered: {
            bluetoothPopup.connectingAddress = ""
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
        onStopped: animating = false
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