import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components"
import "../Popups"
import "../Process"
import Jozet.System 1.0

Rectangle {
    y: 5
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    width: centerRowLayoutId.implicitWidth + 30
    height: Theme.height+10
    color: Theme.bg_2
    radius: Theme.radius

    RowLayout {
        id: centerRowLayoutId
        anchors.fill: parent
        anchors{
            margins: 1
            leftMargin: 15
            rightMargin: 15
        }
        BasePill { 
            icon: "\uf017"; 
            text: currentTime +"   |   "+currentDate
        }
        BasePill { 
            icon: "\uf0c2"
            text: sysManager.weather
        }
    }
}