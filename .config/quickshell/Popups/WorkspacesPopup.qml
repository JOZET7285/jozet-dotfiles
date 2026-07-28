import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"
import "../Modules/Workspaces"

BasePrincipalPopup {
    id: workspacesPopup

    property string searchQuery: ""
    property string selectedWindowAddress: ""
    property string currentMonitor: modelData.name

    width: 370
    anchors.top: leftLand.bottom
    anchors.left: leftLand.left
    anchors.leftMargin: 1

    popupName: "workspaces"

    onOpenChanged: if (open) selectedWindowAddress = ""

    function selectWindow(address) {
        selectedWindowAddress = (selectedWindowAddress === address) ? "" : address
    }
    function moveWindowToWorkspace(address, workspaceId) {
        Quickshell.execDetached(["hyprctl", "dispatch",
            `hl.dsp.window.move({ workspace = ${workspaceId}, follow = false, window = 'address:${address}' })`])
        selectedWindowAddress = ""
    }
    function focusWorkspace(workspaceId) {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ workspace = ${workspaceId} })`])
    }
    function onWorkspaceClicked(workspaceId) {
        if (selectedWindowAddress !== "") moveWindowToWorkspace(selectedWindowAddress, workspaceId)
        else focusWorkspace(workspaceId)
    }

    property var workspaceAppCounts: {
        var counts = {}
        if (SystemManager && SystemManager.workspaces) {
            for (var i = 0; i < SystemManager.workspaces.length; i++) {
                var ws = SystemManager.workspaces[i]
                if (ws) counts[ws.id] = ws.apps ? ws.apps.length : 0
            }
        }
        return counts
    }

    popupContent: Component {
        Item {
            width: workspacesPopup.width
            height: SystemManager.workspaces.length < 2 ? 290 : SystemManager.workspaces.length < 3 ? 530 : 770

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ListWorkspaces { id: listWorkspaces }

                Row {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: 9 
                        
                        delegate: Item {
                            width: 40
                            height: 40

                            visible: !(workspacesPopup.workspaceAppCounts[index + 1] > 0)

                            MouseArea {
                                anchors.fill: parent
                                onClicked: workspacesPopup.onWorkspaceClicked(index + 1)
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.color_2
                                radius: 10
                                border.color: workspacesPopup.selectedWindowAddress !== "" ? Theme.color_3 : Theme.color_1
                                border.width: workspacesPopup.selectedWindowAddress !== "" ? 2 : 1

                                Text { 
                                    anchors.centerIn: parent
                                    text: index + 1 
                                    color: Theme.text_color
                                    opacity: 0.6
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
