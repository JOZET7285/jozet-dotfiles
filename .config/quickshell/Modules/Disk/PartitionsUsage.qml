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
        model: sysManager.partitionsStatus
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
                text: modelData.path
                color: Theme.text_color
                font.bold: true
                font.pixelSize: 12
            }
            Text {
                id: percentPartition
                anchors {
                    right: parent.right
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
                text: modelData.percent + "%"
                color: Theme.text_color
                font.bold: true
                font.pixelSize: 12
            }
            Rectangle {
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
                    width: (parent.width / modelData.totalGb) * modelData.usedGb
                    color: Theme.color_b
                    radius: 10
                }
            }
        }
    }
}