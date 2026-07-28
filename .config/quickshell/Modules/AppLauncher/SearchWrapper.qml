import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../../Components"

Rectangle {
    id: searchWrapper
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: header.bottom
    anchors.topMargin: 10
    height: 32
    radius: 10
    color: Theme.color_1
    border.color: Theme.color_4
    border.width: 1

    Text {
        id: searchIcon
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf002"
        font.pixelSize: 14
        color: Theme.text_color
    }

    TextField {
        id: searchAppField
        anchors.left: searchIcon.right
        anchors.leftMargin: 10
        anchors.right: clearIcon.visible ? clearIcon.left : parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        color: Theme.text_color
        background: Item {}
        leftPadding: 0
        focus: true
        Component.onCompleted: forceActiveFocus()
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
        text: "\uf00d"
        font.family: Theme.iconFont
        font.pixelSize: 13
        color: Theme.text_color

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