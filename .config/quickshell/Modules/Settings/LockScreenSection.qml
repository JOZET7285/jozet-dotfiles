import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components/"

Component {
    id: lockSection
    ColumnLayout {
        spacing: 12
        Text {
            Layout.preferredHeight: 20 
            text: "Lock Screen" 
            font.pixelSize: 16 
            font.bold: true 
            color: Theme.text_color 
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }
        
        Text {
            text: "Lock Screen Container"
            Layout.leftMargin: 20
            font.pixelSize: 14
            font.bold: true
            color: Theme.color_a_text
            Layout.preferredWidth: 100
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            color: Theme.color_2
            radius: 5
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                RowLayout {
                    spacing: 10
                    Text { 
                        Layout.margins: 15
                        text: "Blur:" 
                        font.pixelSize: 12 
                        color: Theme.color_a_text
                        Layout.preferredWidth: 100 
                    }
                    Rectangle {
                        Layout.preferredWidth: 22 
                        Layout.preferredHeight: 22 
                        radius: 5
                        color: Theme.color_3
                        Text {
                            anchors.centerIn: parent
                            text: "-"
                            font.pixelSize: 12
                            color: Theme.color_r_text
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var current = SystemManager.getSetting("display.lockscreen.blur")
                                if(current > 0.84 && current <= 1.0){
                                    var newValue = Math.round((current - 0.02) * 100) / 100;
                                    SystemManager.setSetting("display.lockscreen.blur", newValue)
                                    principalBlur.text = Math.round((newValue - 0.84) / 0.16 * 100) + "%"                                
                                }
                            }
                        }
                    }
                    Text {
                        id: principalBlur
                        text: Math.round((SystemManager.getSetting("display.lockscreen.blur") - 0.84) / 0.16 * 100) + "%"
                        font.pixelSize: 12
                        color: Theme.color_a_text
                        Layout.preferredWidth: 25
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                    Rectangle {
                        Layout.preferredWidth: 22 
                        Layout.preferredHeight: 22 
                        radius: 5
                        color: Theme.color_3
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 12
                            color: Theme.color_b_text
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var current = SystemManager.getSetting("display.lockscreen.blur")
                                if(current >= 0.84 && current < 1.0){
                                    var newValue = ((current + 0.02) * 100) / 100;
                                    SystemManager.setSetting("display.lockscreen.blur", newValue)
                                    principalBlur.text = Math.round((newValue - 0.84) / 0.16 * 100) + "%"
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: 10
                    Text { 
                        Layout.margins: 15
                        text: "Opacity:" 
                        font.pixelSize: 12 
                        color: Theme.color_a_text
                        Layout.preferredWidth: 100 
                    }
                    Rectangle {
                        Layout.preferredWidth: 22 
                        Layout.preferredHeight: 22 
                        radius: 5
                        color: Theme.color_3
                        Text {
                            anchors.centerIn: parent
                            text: "-"
                            font.pixelSize: 12
                            color: Theme.color_r_text
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var current = SystemManager.getSetting("display.lockscreen.opacity")
                                if(current > 0.5 && current <= 1.0){
                                    var newValue = Math.round((current - 0.1) * 10) / 10;
                                    SystemManager.setSetting("display.lockscreen.opacity", newValue)
                                    principalOpacity.text = Math.round((newValue - 0.5) / 0.5 * 100) + "%"
                                }
                            }
                        }
                    }
                    Text {
                        id: principalOpacity
                        text: Math.round((SystemManager.getSetting("display.lockscreen.opacity") - 0.5) / 0.5 * 100) + "%"                        
                        font.pixelSize: 12
                        color: Theme.color_a_text
                        Layout.preferredWidth: 25
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                    Rectangle {
                        Layout.preferredWidth: 22 
                        Layout.preferredHeight: 22 
                        radius: 5
                        color: Theme.color_3
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 12
                            color: Theme.color_b_text
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var current = SystemManager.getSetting("display.lockscreen.opacity")
                                if(current >= 0.5 && current < 1.0){
                                    var newValue = Math.round((current + 0.1) * 10) / 10;
                                    SystemManager.setSetting("display.lockscreen.opacity", newValue)
                                    principalOpacity.text = Math.round((newValue - 0.5) / 0.5 * 100) + "%"
                                }
                            }
                        }
                    }
                }
            }
            

        }
        Text {
            text: "Monitoring"
            Layout.leftMargin: 20
            font.pixelSize: 14
            font.bold: true
            color: Theme.color_a_text
            Layout.preferredWidth: 100
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            color: Theme.color_2
            radius: 5
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                RowLayout {
                    spacing: 10
                    Text { 
                        Layout.margins: 15
                        text: "Left Monitor:" 
                        font.pixelSize: 12 
                        color: Theme.color_a_text
                        Layout.preferredWidth: 100 
                    }
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 22
                        radius: 11
                        color: Theme.color_1
                        Rectangle {
                            id: leftMonitorToggle
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: Theme.color_a_text
                            x: SystemManager.getSetting("display.lockscreen.leftLand") ? 22 : 1
                            Behavior on x { NumberAnimation { duration: 250 }}
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var value = SystemManager.getSetting("display.lockscreen.leftLand")
                                SystemManager.setSetting("display.lockscreen.leftLand", !value)
                                if(!value) leftMonitorToggle.x = 22
                                else leftMonitorToggle.x = 1
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: 10
                    Text { 
                        Layout.margins: 15
                        text: "Right Monitor:" 
                        font.pixelSize: 12 
                        color: Theme.color_a_text
                        Layout.preferredWidth: 100 
                    }
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 22
                        radius: 11
                        color: Theme.color_1
                        Rectangle {
                            id: rightMonitorToggle
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: Theme.color_a_text
                            x: SystemManager.getSetting("display.lockscreen.rightLand") ? 22 : 1
                            Behavior on x { NumberAnimation { duration: 250 }}
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var value = SystemManager.getSetting("display.lockscreen.rightLand")
                                SystemManager.setSetting("display.lockscreen.rightLand", !value)
                                if(!value) rightMonitorToggle.x = 22
                                else rightMonitorToggle.x = 1
                            }
                        }
                    }
                }
            }
        }
        
        Item { Layout.fillHeight: true }
    }
}