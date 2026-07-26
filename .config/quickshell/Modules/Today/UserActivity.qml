import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 100
    color: Theme.color_2 
    radius: 15
    
    RowLayout {
        anchors.fill: parent
        
        Rectangle {
            Layout.preferredWidth: 700/6
            Layout.fillHeight: true
            Layout.margins: 10
            color: Theme.color_4
            radius: 5
            
            ColumnLayout {
                anchors.centerIn: parent
                Text {
                    text: "Uptime"
                    font.pixelSize: 15
                    font.bold: true
                    color: Theme.text_color
                }
                Text {
                    text: (SystemManager.userStats && SystemManager.userStats.uptime) ? SystemManager.userStats.uptime : "0h 0m"
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.text_color_secondary
                }
            }
        }
        
        Repeater {
            model: (SystemManager.userStats && SystemManager.userStats.mostUsedApps) ? SystemManager.userStats.mostUsedApps : []
            
            Rectangle {
                Layout.preferredWidth: 700/5.7
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.bottomMargin: 10

                color: Theme.color_1
                radius: 5
                
                ColumnLayout {
                    anchors.centerIn: parent
                    Text {
                        text: modelData.name
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.text_color
                        elide: Text.ElideRight
                        Layout.maximumWidth: 80 
                    }
                    Text {
                        text: modelData.time
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.text_color_secondary
                    }
                }
            }
        }
    }
}