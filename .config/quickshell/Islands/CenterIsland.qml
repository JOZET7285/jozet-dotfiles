import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Components/Pills"
import "../Popups"
import "../Process"
import Jozet.System 1.0

Rectangle {
    y: 5
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    width: centerRowLayoutId.implicitWidth + 20
    height: 38 * scaleFactor
    color: Theme.color_1
    radius: Theme.radius

    RowLayout {
        id: centerRowLayoutId
        anchors.fill: parent
        anchors{
            margins: 1
            leftMargin: 15 * scaleFactor
            rightMargin: 15 * scaleFactor
        }
        BasePillSimple { 
            icon: "\uf017"; 
            text: currentTime +"   |   "+currentDate
        }
        BasePillSimple { 
            icon: "\uf0c2"
            text: sysManager.weather
        }
    }
}