import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../../Components"

ScrollView {
    Layout.preferredWidth: 350
    Layout.preferredHeight: SystemManager.workspaces.length < 2 ? 220 : SystemManager.workspaces.length < 3 ? 455 : 690
    clip: true

    ListView {
        width: parent.width
        model: SystemManager.workspaces
        spacing: 12
        
        delegate: Item {
            width: ListView.view.width
            height: workspaceRepresent.height + 50

            MouseArea {
                anchors.fill: parent
                onClicked: workspacesPopup.onWorkspaceClicked(modelData.id)
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.color_2
                radius: 12
                border.width: workspacesPopup.selectedWindowAddress !== "" ? 2 : 0
                border.color: Theme.color_3

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text { 
                        text: "Workspace " + modelData.id 
                        color: Theme.text_color
                        font.bold: true
                        font.pixelSize: 14 
                    }

                    Rectangle {
                        id: workspaceRepresent
                        width: 300        
                        height: 300 * (modelData.monitor.height / modelData.monitor.width)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Theme.color_3
                        clip: true

                        readonly property real wsScaleFactor: 300 / modelData.monitor.width
                        readonly property int wsMonitorX: modelData.monitor.x
                        readonly property int wsMonitorY: modelData.monitor.y

                        Repeater {
                            model: modelData.apps
                            delegate: Rectangle {
                                color: Theme.color_1
                                radius: 8
                                z: isSelected ? 100 : 0

                                x: (modelData.x - workspaceRepresent.wsMonitorX) * workspaceRepresent.wsScaleFactor
                                y: (modelData.y - workspaceRepresent.wsMonitorY) * workspaceRepresent.wsScaleFactor
                                
                                width: modelData.w * workspaceRepresent.wsScaleFactor
                                height: modelData.h * workspaceRepresent.wsScaleFactor

                                property string windowAddress: modelData.address
                                property bool isSelected: workspacesPopup.selectedWindowAddress === windowAddress

                                border.width: isSelected ? 2 : 0
                                border.color: isSelected ? Theme.color_a_text : Theme.color_3
                                
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on border.width { NumberAnimation { duration: 150 } }

                                Text {
                                    id: titleApp
                                    anchors.centerIn: parent
                                    text: modelData.class
                                    color: Theme.text_color
                                    font.pixelSize: 13 
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: workspacesPopup.selectWindow(windowAddress)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}