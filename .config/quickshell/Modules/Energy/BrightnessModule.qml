import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"
Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: false
    Layout.preferredHeight: 70 * scaleFactor
    color: Theme.color_2
    radius: 20
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8
        Slider {
            Layout.fillWidth: true
            id: brightnessSlider
            from: 0
            to: 100
            value: sysManager.brightness
            onMoved: {
                sysManager.setBrightness(Math.round(brightnessSlider.value))
            }
            background: Rectangle {
                x: brightnessSlider.leftPadding
                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                implicitHeight: 6
                implicitWidth: brightnessSlider.availableWidth 
                height: implicitHeight
                radius: 3
                color: Theme.color_3
                Rectangle {
                    width: brightnessSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.color_y
                    radius: 3
                }
            }
            handle: Rectangle {
                x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: 6
                color: brightnessSlider.pressed ? Theme.color_y_solid : Theme.color_y

                Behavior on color { ColorAnimation { duration: 100 } }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter 
            text: "Brightness: " + sysManager.brightness + "%"
            color: Theme.text_color
            font.bold: true
            font.pixelSize: 10
        }   
    }
}
