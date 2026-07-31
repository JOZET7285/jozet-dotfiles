import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../../Components"

RowLayout { 
    anchors.fill: parent

    Text {
        id: searchIcon
        Layout.leftMargin: 10
        Layout.alignment: Qt.AlignVCenter
        text: "\uf002"
        font.pixelSize: 14
        color: Theme.text_color
    }

    TextField {
        id: searchAppField
        Layout.fillHeight: true
        Layout.fillWidth: true
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
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: 10
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