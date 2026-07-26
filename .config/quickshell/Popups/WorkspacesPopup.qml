import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../Components"
Item {
    id: workspacesPopup

    property string searchQuery: ""
    property bool open: false
    property bool animating: false
    property string selectedWindowAddress: ""
    property string screenName: ""

    function selectWindow(address) {
        selectedWindowAddress = (selectedWindowAddress === address) ? "" : address
    }

    function moveWindowToWorkspace(address, workspaceId) {
        Quickshell.execDetached([
            "hyprctl",
            "dispatch",
            `hl.dsp.window.move({ workspace = ${workspaceId}, follow = false, window = 'address:${address}' })`
        ]);
        selectedWindowAddress = ""
    }

    function focusWorkspace(workspaceId) {
        Quickshell.execDetached([
            "hyprctl",
            "dispatch",
            `hl.dsp.focus({ workspace = ${workspaceId} })`
        ]);
    }

    function onWorkspaceClicked(workspaceId) {
        if (selectedWindowAddress !== "") {
            moveWindowToWorkspace(selectedWindowAddress, workspaceId)
        } else {
            focusWorkspace(workspaceId)
        }
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

    readonly property int contentWidth: 370
    width: contentWidth
    height: SystemManager.workspaces.length < 2 ? 300 : SystemManager.workspaces.length < 3 ? 530 : 760
    anchors.top: leftLand.bottom
    anchors.left: leftLand.left
    anchors.leftMargin: 1
    clip: true
    visible: open || animating

    onOpenChanged: { 
        if (open) {
            selectedWindowAddress = "";
            contentLoader.active = true; 
        } else {
            if(contentLoader.item){
                contentLoader.item.startCloseAnimation();
            }
        }
    }

    function closeLauncher() {
        workspacesPopup.open = false
    }
    IpcHandler {
        target: "workspacesPopup-"+currentMonitor
        function toggle(): void { workspacesPopup.open = !workspacesPopup.open }
        function show(): void { workspacesPopup.open = true }
        function hide(): void { workspacesPopup.open = false }
    }
    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: popupContent
    }
    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command);
            workspacesPopup.closeLauncher();
        }
    }
    Component {
        id: popupContent
        Item {
            id: internalRoot
            anchors.fill: parent

            Component.onCompleted: {
                workspacesPopup.animating = true;
                openAnim.start();
            }

            function startCloseAnimation() {
                workspacesPopup.animating = true;
                closeAnim.start();
            } 
            Item {
                id: containerWrapper
                anchors.fill: parent

                Rectangle {
                    id: container
                    width: parent.width
                    height: {
                        if(SystemManager.workspaces.length < 2) return 225
                        if(SystemManager.workspaces.length < 3) return 460
                        else return 695
                    }
                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: Theme.radius
                    bottomRightRadius: Theme.radius
                    y: -570
                    color: "transparent"

                    Item {
                        id: content
                        anchors.fill: parent
                        anchors.margins: 10
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10

                            ScrollView {
                                Layout.fillWidth: false
                                Layout.preferredWidth: 350
                                Layout.preferredHeight: {
                                    if(SystemManager.workspaces.length < 2) return 220
                                    if(SystemManager.workspaces.length < 3) return 455
                                    else return 690
                                }
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

            ParallelAnimation {
                id: openAnim
                PropertyAnimation { target: container; property: "y"; to: 0; duration: 220; easing.type: Easing.OutCubic }
                onStopped: {
                    workspacesPopup.animating = false
                }
            }

            ParallelAnimation {
                id: closeAnim
                PropertyAnimation { target: container; property: "y"; to: -570; duration: 220; easing.type: Easing.InCubic }
                onStopped: {
                    workspacesPopup.animating = false
                    contentLoader.active = false
                    gc()
                }
            }
        }
    }
}
