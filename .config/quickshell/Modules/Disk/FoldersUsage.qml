import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"
Item { 
    property var sysManager
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
                    text: (modelData.sizeMb ? modelData.sizeMb : "0") + " MB" 
                    color: Theme.text_color
                    font.bold: true
                    font.pixelSize: 12
                }
            }
        }
    }
}