import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property color color_text: Theme.color_b
    property color color_icon: Theme.text_color
    signal clicked()

    Layout.preferredHeight: parent.height - 5
    Layout.preferredWidth: btnAppLauncherContent.implicitWidth + 25 
    color: "transparent"
    RowLayout {
        id: btnAppLauncherContent
        anchors.fill: parent
        anchors.leftMargin: 10 * scaleFactor
        anchors.rightMargin: 10 * scaleFactor
        spacing: 5 * scaleFactor
        
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Text {
            Layout.alignment: Qt.AlignVCenter
            visible: root.icon.length > 0
            text: root.icon
            color: color_icon
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Behavior on color { ColorAnimation { duration: 200; easing: Easing.InOutQuad }}
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            visible: root.text.length > 0
            text: root.text
            color: color_text
            font.pixelSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Behavior on color { ColorAnimation { duration: 200; easing: Easing.InOutQuad }}
        }
    }

    MouseArea {
        id: maAppLauncherBtn
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}