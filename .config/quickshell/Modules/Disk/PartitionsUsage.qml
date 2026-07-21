import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"
Item {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15
        text: "Partitions"
        color: Theme.text_color
        font.pixelSize: 12
        font.bold: true
    }
    ListView {
        id: partitionsListView
        anchors.fill: parent
        anchors.topMargin: 20
        model: {
            var combined = [];
            var parts = sysManager.partitionsStatus;
            for (var i = 0; i < parts.length; i++) {
                combined.push({
                    label: parts[i].path,
                    percent: parts[i].percent,
                    totalGb: parts[i].totalGb,
                    usedGb: parts[i].usedGb,
                    isUsb: false,
                    mounted: true,
                    usbPath: ""
                });
            }
            var usb = sysManager.usbDevices;
            for (var j = 0; j < usb.length; j++) {
                combined.push({
                    label: usb[j].name || usb[j].path.split('/').pop(),
                    percent: usb[j].percent,
                    totalGb: usb[j].totalGb,
                    usedGb: usb[j].usedGb,
                    isUsb: true,
                    mounted: usb[j].mounted,
                    usbPath: usb[j].devicePath
                });
            }
            return combined;
        }
        clip: true

        delegate: Item {
            width: partitionsListView.width
            height: 40

            Text {
                id: pathPartitionName
                anchors {
                    left: parent.left
                    leftMargin: 15
                    verticalCenter: parent.verticalCenter
                }
                text: modelData.label + (modelData.isUsb ? "  \u26a0" : "")
                color: Theme.text_color
                font.bold: true
                font.pixelSize: 12
            }

            Text {
                id: percentPartition
                visible: modelData.mounted
                anchors {
                    right: parent.right
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
                text: modelData.percent.toFixed(1) + "%"
                color: Theme.text_color
                font.bold: true
                font.pixelSize: 12
            }
            Rectangle {
                visible: modelData.mounted
                width: parent.width - pathPartitionName.width - percentPartition.width - 50
                height: 15
                radius: 10
                color: Theme.color_2
                anchors {
                    left: pathPartitionName.right
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                clip: true
                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: modelData.totalGb > 0 ? (parent.width / modelData.totalGb) * modelData.usedGb : 0
                    color: modelData.isUsb ? Theme.color_g : Theme.color_b
                    radius: 10
                }
            }

            // No montado: boton para montar
            Rectangle {
                visible: !modelData.mounted
                width: 80
                height: 26
                radius: 6
                color: Theme.color_g
                anchors {
                    right: parent.right
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sysManager.mountUsbDevice(modelData.usbPath)
                }
                Text {
                    anchors.centerIn: parent
                    text: "Montar"
                    font.pixelSize: 11
                    font.bold: true
                    color: "white"
                }
            }
        }
    }
}
