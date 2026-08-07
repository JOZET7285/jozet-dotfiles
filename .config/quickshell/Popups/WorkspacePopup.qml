import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"
import "../Modules/Today"
import Jozet.System 1.0

BasePopup {
    id: workspacesPopup

    customWidth: 1580

    property var currentMonitor: {
        var screenName = modelData ? modelData.name : ""
        for (var i = 0; i < SystemManager.workspaces.length; i++) {
            if (SystemManager.workspaces[i].name === screenName) return SystemManager.workspaces[i]
        }
        return null
    }
    
    property string selectedWindowAddress: ""
    property var workspaceAppCounts: {
        var counts = {}
        if (currentMonitor && currentMonitor.workspaces) {
            for (var w = 0; w < currentMonitor.workspaces.length; w++) {
                var ws = currentMonitor.workspaces[w]
                if (ws) counts[ws.id] = ws.apps ? ws.apps.length : 0
            }
        }
        return counts
    }

    ipcTarget: "workspacePopup-" + (currentMonitor ? currentMonitor.name : "")

    onOpenChanged: if (open) selectedWindowAddress = ""

    function selectWindow(address) {
        selectedWindowAddress = (selectedWindowAddress === address) ? "" : address
    }
    function moveWindowToWorkspace(address, workspaceId) {
        var wsSelector = typeof workspaceId === "number" ? workspaceId : `'${workspaceId}'`
        Quickshell.execDetached(["hyprctl", "eval",
            `hl.dispatch(hl.dsp.window.move({ workspace = ${wsSelector}, follow = false, window = 'address:${address}' }))`])
        selectedWindowAddress = ""
    }
    function focusWorkspace(workspaceId) {
        Quickshell.execDetached(["hyprctl", "eval", `hl.dispatch(hl.dsp.focus({ workspace = ${workspaceId} }))`])
    }
    function onWorkspaceClicked(workspaceId) {
        if (selectedWindowAddress !== "") moveWindowToWorkspace(selectedWindowAddress, workspaceId)
        else focusWorkspace(workspaceId)
    }

    popupContent: Component {
        ColumnLayout {
            id: mainLayout
            spacing: 10

            GridLayout {
                columns: 5
                rowSpacing: 15
                columnSpacing: 15
                
                Repeater {
                    model: currentMonitor ? currentMonitor.workspaces : []
                    
                    delegate: Rectangle {
                        id: workspaceItem
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: workspaceContent.implicitHeight + 20
                        color: Theme.color_2
                        radius: 12

                        MouseArea {
                            anchors.fill: parent
                            onClicked: workspacesPopup.onWorkspaceClicked(modelData.id)
                        }

                        ColumnLayout {
                            id: workspaceContent
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Text {
                                text: "Workspace " + modelData.id 
                                color: Theme.text_color
                                font.bold: true
                                font.pixelSize: 14 
                            }
                            
                            Rectangle {
                                id: workspaceRepresent
                                Layout.fillWidth: true
                                Layout.preferredHeight: width * (currentMonitor.height / currentMonitor.width)
                                clip: true
                                color: Theme.color_3
                                radius: 12

                            readonly property real wsScaleFactor: width / currentMonitor.width
                            readonly property int wsMonitorX: currentMonitor.x
                            readonly property int wsMonitorY: currentMonitor.y

                            MouseArea {
                                anchors.fill: parent
                                onClicked: workspacesPopup.onWorkspaceClicked(modelData.id)
                            }

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
                                    border.color: isSelected ? Theme.color_a_text : "transparent"
                                    
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
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 15

                Row {
                    spacing: 10
                    
                    Repeater {
                        model: [
                            { idName: "music", label: "M" },
                            { idName: "terminal", label: "T" },
                            { idName: "special", label: "S" }
                        ]
                        
                        delegate: Rectangle {
                            width: 35
                            height: 35
                            color: Theme.color_2
                            radius: 10
                            border.color: workspacesPopup.selectedWindowAddress !== "" ? Theme.color_3 : Theme.color_1
                            border.width: workspacesPopup.selectedWindowAddress !== "" ? 2 : 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: Theme.text_color
                                font.bold: true
                                font.pixelSize: 14
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (workspacesPopup.selectedWindowAddress !== "") {
                                        workspacesPopup.moveWindowToWorkspace(workspacesPopup.selectedWindowAddress, "special:" + modelData.idName)
                                    } else {
                                        Quickshell.execDetached(["hyprctl", "eval", `hl.dispatch(hl.dsp.workspace.toggle_special("${modelData.idName}"))`])
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 25
                    color: Theme.color_3
                    radius: 1
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Repeater {
                        model: 9
                        delegate: Rectangle {
                            width: 35
                            height: 35
                            visible: !(workspacesPopup.workspaceAppCounts[index + 1] > 0)
                            color: Theme.color_2
                            radius: 10
                            border.color: workspacesPopup.selectedWindowAddress !== "" ? Theme.color_3 : Theme.color_1
                            border.width: workspacesPopup.selectedWindowAddress !== "" ? 2 : 1

                            Text {
                                anchors.centerIn: parent
                                text: index + 1
                                color: Theme.text_color
                                opacity: 0.6
                                font.bold: true
                                font.pixelSize: 14
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: workspacesPopup.onWorkspaceClicked(index + 1)
                            }
                        }
                    }
                }
            }
        }
    }
}