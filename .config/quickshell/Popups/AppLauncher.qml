import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"

PanelWindow {
    id: appLauncher

    property string searchQuery: ""
    property bool open: false
    property bool animating: false

    width: 430; height: 570
    anchors {
        top: true
        left: true
    }
    color: '#00000000'
    visible: open || animating
    focusable: true
    aboveWindows: true

    onOpenChanged: {
        if (open) {
            searchQuery = "";
            Qt.callLater(function() {
                searchAppField.text = "";
                visible = true;
                animating = true;
                openAnim.start();
                searchAppField.forceActiveFocus();
            })
        } else {
            Qt.callLater(function() {
                animating = true;
                closeAnim.start();
            })
        }
    }

    function closeLauncher() {
        appLauncher.open = false
    }
    IpcHandler {
        target: "appLauncher"

        function toggle(): void {
            appLauncher.open = !appLauncher.open
        }
        function show(): void {
            appLauncher.open = true
        }
        function hide(): void {
            appLauncher.open = false
        }
    }
    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command);
            appLauncher.closeLauncher();
        }
    }

    Item {
        id: containerWrapper
        anchors.fill: parent

        Rectangle {
            id: container
            // anchors.fill: parent
            width: 420
            height: 560
            radius: Theme.radius
            x: 10
            y: -570
            color: Theme.bg_1



            Item {
                id: content
                anchors.fill: parent
                anchors.margins: 16

                RowLayout {
                    id: header
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 22

                    Text {
                        text: "Aplicaciones"
                        color: Theme.text_color
                        font.pixelSize: 15
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: appListModel.values.length + " resultado" + (appListModel.values.length === 1 ? "" : "s")
                        color: Theme.text_dim
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    id: searchWrapper
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: header.bottom
                    anchors.topMargin: 10
                    height: 42
                    radius: 10
                    color: Theme.bg_2
                    border.color: searchAppField.activeFocus ? Theme.accent : Theme.border_color
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Text {
                        id: searchIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf002" // nf-fa-search
                        font.family: Theme.iconFont
                        font.pixelSize: 14
                        color: Theme.text_dim
                    }

                    TextField {
                        id: searchAppField
                        placeholderText: "Buscar aplicación..."
                        anchors.left: searchIcon.right
                        anchors.leftMargin: 10
                        anchors.right: clearIcon.visible ? clearIcon.left : parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        color: Theme.text_color
                        background: Item {}
                        leftPadding: 0
                        onTextChanged: {
                            appLauncher.searchQuery = text
                        }
                        Keys.onEscapePressed: appLauncher.closeLauncher()
                        Keys.onReturnPressed: {
                            if (appListModel.values.length > 0) appLauncher.launch(appListModel.values[0])
                        }
                    }

                    Text {
                        id: clearIcon
                        visible: searchAppField.text.length > 0
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf00d" // nf-fa-times
                        font.family: Theme.iconFont
                        font.pixelSize: 13
                        color: Theme.text_dim

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchAppField.text = ""
                                searchAppField.forceActiveFocus()
                            }
                        }
                    }
                }

                GridView {
                    id: appGrid
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: searchWrapper.bottom
                        margins: 12
                        bottom: parent.bottom
                    }
                    cellWidth: 70
                    cellHeight: 95
                    clip: true
                    flow: GridView.FlowTopToRight

                    visible: appListModel.values.length > 0
                    contentHeight: Math.ceil(count / 3) * cellHeight

                    ScrollBar.vertical: ScrollBar {
                        id: verticalScrollBar
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: Theme.text_dim
                        }
                    }

                    model: ScriptModel {
                        id: appListModel
                        values: {
                            return [...DesktopEntries.applications.values]
                                .filter(function(app) {
                                    return app.name && !app.noDisplay && app.name.toLowerCase().includes(appLauncher.searchQuery.toLowerCase())
                                })
                                .sort(function(a, b) { return a.name.localeCompare(b.name) })
                        }
                    }

                    delegate: Item {
                        id: delegateRoot
                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight

                        property bool hovered: appMouseArea.containsMouse

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 10
                            color: delegateRoot.hovered ? Theme.bg_hover : "transparent"
                            border.color: delegateRoot.hovered ? Theme.border_color : "transparent"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: appMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: appLauncher.launch(modelData)
                        }

                        Column {
                            anchors.centerIn: parent
                            width: parent.width
                            spacing: 8
                            scale: delegateRoot.hovered ? 1.08 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 36
                                height: 36
                                source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true

                                Text {
                                    anchors.centerIn: parent
                                    visible: parent.status !== Image.Ready
                                    text: "\uf108" // nf-fa-desktop (fallback)
                                    font.family: Theme.iconFont
                                    font.pixelSize: 28
                                    color: Theme.text_dim
                                }
                            }

                            Text {
                                width: parent.width - 12
                                text: modelData.name
                                color: Theme.text_color
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Empty state
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: appListModel.values.length === 0
                    spacing: 8

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "\uf05e" // nf-fa-ban
                        font.family: Theme.iconFont
                        font.pixelSize: 32
                        color: Theme.text_dim
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No se encontraron aplicaciones"
                        color: Theme.text_dim
                        font.pixelSize: 13
                    }
                }
            }
        }
    }

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: container; property: "y"; to: 10; duration: 220; easing.type: Easing.OutCubic }
        // PropertyAnimation { target: container; property: "opacity"; to: 1; duration: 260 }
        onStopped: {
            animating = false
        }
    }

    ParallelAnimation {
        id: closeAnim
        PropertyAnimation { target: container; property: "y"; to: -570; duration: 220; easing.type: Easing.InCubic }
        // PropertyAnimation { target: container; property: "opacity"; to: 0; duration: 220 }
        onStopped: {
            animating = false
            visible = false
        }
    }
}
