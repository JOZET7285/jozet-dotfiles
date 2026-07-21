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
        text: "Storage (/home)"
        font.pixelSize: 12
        color: Theme.text_color
        font.bold: true
    }

    ListView {
        id: folderListView
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.rightMargin: 8
        model: sysManager.homeFoldersUsage
        clip: true

        delegate: Item {
            width: folderListView.width
            height: 40

            Rectangle {
                anchors {
                    fill: parent
                    margins: 5
                }
                color: Theme.color_2
                radius: 10

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 15
                        verticalCenter: parent.verticalCenter
                    }
                    text: modelData.name 
                    color: Theme.text_color
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    anchors {
                        right: parent.right
                        rightMargin: 15
                        verticalCenter: parent.verticalCenter
                    }
                    text: (modelData.sizeMb ? modelData.sizeMb.toFixed(1) : "0") + " MB" 
                    color: Theme.text_color
                    font.bold: true
                    font.pixelSize: 12
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: folderListView.contentHeight > folderListView.height
                    ? ScrollBar.AsNeeded
                    : ScrollBar.AlwaysOff
            width: 6
            contentItem: Rectangle {
                implicitWidth: 6
                implicitHeight: 10
                radius: 3
                color: parent.pressed ? Theme.color_3 : Theme.text_color
                opacity: folderListView.contentHeight > folderListView.height ? 0.5 : 0
            }
            background: Rectangle {
                color: Theme.color_1
                radius: 3
            }
        }
    }
}