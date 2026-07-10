import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components"

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredHeight: 100
        spacing: 8
        Rectangle {
            color: Theme.bg_2
            radius: height/2
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            Text {
                color: Theme.color_text2
                text: "\uf240"
                font.pixelSize: 40
                anchors.centerIn: parent
            }
            border {
                width: 1
                color: Theme.bg_3
            }
        }
        Rectangle {
            color: Theme.bg_2_solid
            radius: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4
                    Text {
                        text: "Batería"
                        color: Theme.text_color
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "10% - Cargando"
                        color: Theme.text_color2
                        font.pixelSize: 11
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "Tiempo restante"
                        color: Theme.text_color
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "1h 30m"
                        color: Theme.text_color2
                        font.pixelSize: 11
                        Layout.fillWidth: true
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    Layout.fillHeight: true
                    color: Theme.bg_4
                    radius: 10
                    Text {
                        text: "Rendimiento"
                        
                    }
                }
            }
        }
    }
}