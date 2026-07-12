import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../../Components"
import "../../Components"
RowLayout {
    Layout.fillWidth: true
    Layout.fillHeight: false
    Layout.preferredHeight: 100
    spacing: 8

    Item {
        id: batteryCircle
        Layout.preferredWidth: 100
        Layout.preferredHeight: 100
        Layout.fillHeight: false
        Layout.fillWidth: false

        property int capacity: sysManager.batteryCapacity
        property string status: sysManager.batteryStatus

        property color fillColor: {
            if (status === "Charging") return Theme.color_g;
            if (status === "Full") return Theme.color_b;
            if (capacity > 90) return Theme.color_b;
            if (capacity > 60) return Theme.color_y;
            if (capacity > 30) return Theme.color_o;
            return Theme.color_r;
        }

        Rectangle {
            id: bgCircle
            anchors.fill: parent
            radius: width / 2
            color: Theme.color_1
        }

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false 

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height * (batteryCircle.capacity / 100)
                color: batteryCircle.fillColor

                Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }

        Rectangle {
            id: circleMask
            anchors.fill: parent
            radius: width / 2
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: fillSource
            maskSource: circleMask
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: Theme.color_3
            border.width: 1
        }
        Text {
            color: Theme.text_color
            text: "\uf240"
            font.pixelSize: 40
            anchors.centerIn: parent
        }
    }

    Rectangle {
        color: Theme.color_1_solid
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
                    text: "Battery"
                    color: Theme.text_color
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: sysManager.batteryCapacity + "% - " + sysManager.batteryStatus
                    color: {
                        if(sysManager.batteryStatus === "Charging") return Theme.color_g
                        else if (sysManager.batteryStatus === "Full") return Theme.color_b
                        else{
                            if (sysManager.batteryCapacity > 90) return Theme.text_color
                            if (sysManager.batteryCapacity > 60) return Theme.color_y
                            if (sysManager.batteryCapacity > 30) return Theme.color_o
                            return Theme.color_r
                        }
                    }
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    font.bold: true
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
                    color: Theme.color_g
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    font.bold: true
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                color: {
                    if(sysManager.powerProfile === "performance"){
                        return changePowerProfileMa.containsMouse ? Theme.color_o : Theme.color_o_solid
                    }else if (sysManager.powerProfile === "balanced"){
                        return changePowerProfileMa.containsMouse ? Theme.color_y : Theme.color_y_solid
                    }
                    return changePowerProfileMa.containsMouse ? Theme.color_g : Theme.color_g_solid
                }
                radius: 20
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }}
                Column{
                    anchors.centerIn: parent
                    spacing: 1
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: sysManager.powerProfile
                        font.capitalization: Font.AllUppercase
                        font.bold: true
                        font.pixelSize: 14
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "click to change"
                        font.pixelSize: 10
                        color: Theme.color_3
                    }
                }
                MouseArea {
                    id: changePowerProfileMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(sysManager.powerProfile === "performance") {
                            sysManager.setPowerProfile("balanced");
                        } else if (sysManager.powerProfile === "balanced") {
                            sysManager.setPowerProfile("power-saver");
                        } else {
                            sysManager.setPowerProfile("performance");
                        }
                    }
                }
            }
        }
    }
}