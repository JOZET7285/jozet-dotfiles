import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components/"

BasePopup {
    id: cpuPopup
    customWidth: 500
    ipcTarget: "cpuPopup"

    popupContent: Component {
        ColumnLayout {
            id: mainLayout
            spacing: 15
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    RowLayout {
                        Text {
                            text: "Global Usage"
                            color: Theme.text_color
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        Text {
                            text: sysManager.cpuUsage + "%"
                            color: Theme.text_color
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        color: Theme.color_3
                        radius: 3
                        
                        Rectangle {
                            width: parent.width * (sysManager.cpuUsage / 100)
                            height: parent.height
                            color: Theme.color_b
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    spacing: 5
                    Text {
                        text: sysManager.cpuFrequency + " MHz"
                        color: Theme.light_3
                        font.pixelSize: 13
                    }
                }
            }   
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                color: Theme.light_4
            }
            Text {
                text: "Top Processes"
                color: Theme.light_1
                font.pixelSize: 13
                font.bold: true
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 5 * 30
                spacing: 4

                Repeater {
                    model: (sysManager.topCpuProcesses || []).slice(0, 5)

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 26

                        Text {
                            text: modelData.name
                            color: Theme.text_color
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            color: Theme.color_3
                        }
                        Text {
                            text: modelData.usagePercent + "%"
                            color: Theme.text_color
                            opacity: 0.6
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
    