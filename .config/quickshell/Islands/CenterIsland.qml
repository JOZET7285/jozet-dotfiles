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
    property var centerActivePopup: null
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    width: centerRowLayoutId.implicitWidth + 20
    height: 38 * scaleFactor
    color: Theme.color_1_solid
    bottomLeftRadius: 38
    bottomRightRadius: 38
    

    RowLayout {
        id: centerRowLayoutId
        anchors.fill: parent
        anchors{
            margins: 1
            leftMargin: 15 * scaleFactor
            rightMargin: 15 * scaleFactor
        }
        Rectangle {
            Layout.preferredWidth: pillTodayMa.containsMouse ? 175 : 150 
            Layout.preferredHeight: 29 * scaleFactor
            color: pillTodayMa.containsMouse ? Theme.color_1 : "transparent"
            radius: 8 * scaleFactor
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad}}
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                Text {
                    text: "\uf017"  
                    color: Theme.text_color
                    font {
                        bold: true
                        pixelSize: 14
                    }
                }
                Text {
                    text: currentTime
                    color: Theme.color_b
                    font {
                        bold: true
                        pixelSize: 12
                    }
                }
                Text {
                    anchors.leftMargin: 10
                    text: "\uf073"
                    color: Theme.text_color
                    font {
                        bold: true
                        pixelSize: 14
                    }
                }
                Text {
                    text: currentDate
                    color: Theme.color_b
                    font {
                        bold: true
                        pixelSize: 12
                    }
                }
            } 
            MouseArea {
                id: pillTodayMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: todayPopup.open = !todayPopup.open
                cursorShape: Qt.PointingHandCursor
            }
        }
        BasePillSimple { 
            icon: "\uf0c2"
            text: sysManager.weather
            color_text: {
                let patron = /\+?(\d+)°/;
                let weather = (sysManager.weather).match(patron);
                if (weather && weather[1]) {
                    let temperatura = parseInt(weather[1], 10);
                    
                    if (temperatura < 15) {
                        return Theme.color_b;
                    } if ( temperatura < 23) {
                        return Theme.color_g
                    } if (temperatura < 30) {
                        return Theme.color_y
                    } if (temperatura < 35) {
                        return Theme.color_o
                    }
                    else {
                        return "red";
                    }
                }
                return Theme.text_color;
            }
        }
    }
}