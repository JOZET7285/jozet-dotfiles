import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../Components"
Item {
    id: workspacesPopup

    property string screenName: ""
    property string searchQuery: ""
    property bool open: false
    property bool animating: false
    property string selectedWindowAddress: ""

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
        if (sysManager && sysManager.workspaces) {
            for (var i = 0; i < sysManager.workspaces.length; i++) {
                var ws = sysManager.workspaces[i]
                if (ws) counts[ws.id] = ws.apps ? ws.apps.length : 0
            }
        }
        return counts
    }

    readonly property int contentWidth: 370
    width: contentWidth
    height: 700
    anchors.top: leftLand.bottom
    anchors.left: leftLand.left
    anchors.leftMargin: 1
    clip: true
    visible: open || animating

    onOpenChanged: { 
        if (open) {
            searchQuery = "";
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
        target: "workspacesPopup"
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
                    height: 690
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
                            spacing: 15

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 600
                                clip: true

                                ListView {
                                    width: parent.width
                                    model: sysManager.workspaces
                                    spacing: 12
                                    
                                    delegate: Item {
                                        width: ListView.view.width
                                        height: 220

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: workspacesPopup.onWorkspaceClicked(modelData.id)
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: Theme.color_2
                                            radius: 12
                                            border.width: workspacesPopup.selectedWindowAddress !== "" ? 2 : 0
                                            border.color: Theme.color_1

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
                                                    width: 300
                                                    height: 169
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    color: Theme.color_3

                                                    Repeater {
                                                        model: modelData.apps
                                                        delegate: Rectangle {
                                                            color: Theme.color_1
                                                            radius: 8
                                                            z: isSelected ? 100 : 0

                                                            x: (modelData.x * 300) / 1920
                                                            y: (modelData.y * 169) / 1080
                                                            width: (modelData.w * 300) / 1920
                                                            height: (modelData.h * 169) / 1080

                                                            property string windowAddress: modelData.address
                                                            property bool isSelected: workspacesPopup.selectedWindowAddress === windowAddress

                                                            border.width: isSelected ? 2 : 0
                                                            border.color: Theme.color_3
                                                            scale: isSelected ? 1.05 : 1.0
                                                            Behavior on scale { NumberAnimation { duration: 120 } }

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
                                        width: 50
                                        height: 50

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
