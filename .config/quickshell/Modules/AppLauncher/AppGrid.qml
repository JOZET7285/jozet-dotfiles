import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../../Components"

GridView {
    id: appGrid
    anchors {
        left: parent.left
        right: parent.right
        top: searchWrapper.bottom
        margins: 12
        bottom: parent.bottom
    }
    cellWidth: 90
    cellHeight: 95
    clip: true
    flow: GridView.FlowLeftToRight

    visible: appListModel.values.length > 0
    contentHeight: Math.ceil(count / 3) * cellHeight
    reuseItems: true

    ScrollBar.vertical: ScrollBar {
        id: verticalScrollBar
        policy: ScrollBar.AsNeeded
        contentItem: Rectangle {
            implicitWidth: 5
            radius: 3
            color: Theme.light_3
        }
    }

    delegate: Item {
        id: delegateRoot
        width: GridView.view.cellWidth
        height: GridView.view.cellHeight

        property bool hovered: appMouseArea.containsMouse

        TableView.onReused: {
            appMouseArea.hovered = false
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 10
            color: delegateRoot.hovered || index === 0 ? Theme.color_3 : "transparent"

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
            spacing: 10
            scale: delegateRoot.hovered ? 1.08 : 1.0
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 36
                source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: parent.status !== Image.Ready
                    text: "\uf108"
                    font.family: Theme.iconFont
                    font.pixelSize: 25
                    color: Theme.color_3
                }
            }

            Text {
                width: parent.width
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