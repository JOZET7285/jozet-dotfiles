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

    readonly property int contentWidth: 320
    width: contentWidth-5
    height: 562
    anchors.top: leftLand.bottom
    anchors.left: leftLand.left
    anchors.leftMargin: 1
    clip: true
    visible: open || animating

    onOpenChanged: {
        if (open) {
            searchQuery = "";
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
                    height: 560
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
                            spacing: 10

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 300
                                clip: true

                                ListView {
                                    width: parent.width
                                    model: sysManager.activeWorkspacesModel

                                    delegate: DropArea {
                                        width: ListView.view.width
                                        height: 80

                                        onDropped: (drag) => {
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            
                                            Text { text: "Workspace " + model.id }

                                            RowLayout {
                                                Repeater {
                                                    model: model.apps
                                                    delegate: Rectangle {
                                                        width: 40; height: 40
                                                    
                                                        Drag.active: dragArea.drag.active
                                                        Drag.hotSpot.x: width / 2
                                                        Drag.hotSpot.y: height / 2
                                                        Drag.keys: ["window_address_" + model.address]

                                                        MouseArea {
                                                            id: dragArea
                                                            anchors.fill: parent
                                                            drag.target: parent
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
                                spacing: 5

                                Repeater {
                                    model: sysManager.inactiveWorkspacesModel
                                    
                                    delegate: DropArea {
                                        width: 50; height: 50

                                        onDropped: (drag) => {
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: "gray"
                                            Text { 
                                                anchors.centerIn: parent
                                                text: model.id 
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
