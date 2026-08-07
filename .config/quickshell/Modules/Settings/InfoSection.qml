import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: systemSection
    ColumnLayout {
        spacing: 8
        property url faceImage: {            
            let configHome = Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME"));
            return "file:/" + configHome + "/.local/share/jzt/assets/.face";
        }
        property var info: SystemManager.systemInfo

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "System Info"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
            Item { Layout.fillWidth: true }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Rectangle{
            id: userInfo
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: rowUserInfo.implicitWidth + 40
            Layout.preferredHeight: 100
            color: Theme.color_2
            radius: 10
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            RowLayout {
                id: rowUserInfo
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 20
                Item {
                    Layout.preferredWidth: 70 
                    Layout.preferredHeight: 70
                    Layout.alignment: Qt.AlignVCenter 
                    Image {
                        id: artImage
                        anchors.fill: parent
                        source: faceImage
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                    }
                    MultiEffect {
                        anchors.fill: parent
                        source: artImage
                        maskEnabled: true
                        maskSource: artMask
                    }
                    Item {
                        id: artMask
                        width: parent.width
                        height: parent.height
                        visible: false
                        layer.enabled: true
                        Rectangle {
                            anchors.fill: parent
                            radius: 35
                            color: Theme.color_1_solid
                        }
                    }
                }
                ColumnLayout{
                    Layout.fillHeight: true
                    Text {
                        Layout.alignment: Qt.AlignHCenter 
                        text: info.username
                        font.pixelSize: 18
                        font.bold: true
                        color: Theme.color_a_text
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: info.hostname
                        font.pixelSize: 14
                        font.bold: true
                        color: Theme.text_color_secondary
                    }
                }

                Rectangle {Layout.fillHeight: true; Layout.preferredWidth: 2; Layout.margins: 10; color: Theme.color_3}

                ColumnLayout {
                    Layout.fillHeight: true
                    Text {
                        Layout.alignment: Qt.AlignHCenter 
                        text: info.os
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: info.kernel
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.text_color_secondary
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 2; Layout.margins: 4; color: Theme.color_3 }

                    Text {
                        Layout.alignment: Qt.AlignHCenter 
                        text: "Uptime"
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (SystemManager.userStats && SystemManager.userStats.uptime) ? SystemManager.userStats.uptime : "0h 0m"
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.text_color_secondary
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: systemInfo
                anchors {
                    top: parent.top
                    left: parent.left
                }
                width: (parent.width / 2) - 4
                color: Theme.color_2
                height: colSystemInfo.implicitHeight + 20
                radius: 5
                ColumnLayout {
                    id: colSystemInfo
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Repeater {
                        model: [
                            { "name": "Arch", "value": info.arch },
                            { "name": "WM", "value": info.wm },
                            { "name": "Shell", "value": info.shell},
                            { "name": "Protocol", "value": info.protocol }
                        ]
                        RowLayout {
                            Text {
                                text: modelData.name
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.color_a_text
                            }
                            Rectangle {Layout.fillWidth: true; Layout.preferredHeight: 2; color: Theme.color_3}
                            Text {
                                text: modelData.value
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.text_color_secondary
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: cpuInfo
                anchors {
                    top: parent.top
                    right: parent.right
                }
                width: (parent.width / 2) - 4
                color: Theme.color_2
                height: colCpuInfo.implicitHeight + 20
                radius: 5
                ColumnLayout {
                    id: colCpuInfo
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Repeater {
                        model: {
                            let partes = info.cpuCores.split("/")
                            let cores = partes[0] ? partes[0].replace("C", "").trim() : ""
                            let threads = partes[1] ? partes[1].replace("T", "").trim() : ""
                            
                            return [
                                { "name": "CPU", "value": info.cpu },
                                { "name": "Freq", "value": info.cpuFreq },
                                { "name": "Cores", "value": cores },
                                { "name": "Threads", "value": threads }
                            ]
                        }
                        RowLayout {
                            Text {
                                text: modelData.name
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.color_a_text
                            }
                            Rectangle {Layout.fillWidth: true; Layout.preferredHeight: 2; color: Theme.color_3}
                            Item {
                                visible: modelData.name === "CPU"
                                id: marqueeContainer
                                width: 100 
                                height: 15
                                clip: true 

                                Text {
                                    id: walkingText
                                    text: modelData.value
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: Theme.text_color_secondary
                                    x: 0 

                                    SequentialAnimation {
                                        loops: Animation.Infinite
                                        running: walkingText.contentWidth > marqueeContainer.width

                                        PropertyAction {
                                            target: walkingText
                                            property: "x"
                                            value: 0
                                        }

                                        PauseAnimation {
                                            duration: 2000
                                        }

                                        NumberAnimation {
                                            target: walkingText
                                            property: "x"
                                            from: 0
                                            to: -walkingText.contentWidth
                                            duration: 5000
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: modelData.name !== "CPU"
                                Layout.maximumWidth: 150
                                text: modelData.value
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.text_color_secondary
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: ramInfo
                anchors {
                    top: systemInfo.bottom
                    left: parent.left
                    topMargin: 8
                }
                width: (parent.width / 2) - 4
                color: Theme.color_2
                height: colRamInfo.implicitHeight + 20
                radius: 5
                ColumnLayout {
                    id: colRamInfo
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Repeater {
                        model:[
                            { "name": "Memory", "value": info.ramTotal},
                            { "name": "Swap", "value": (SystemManager.ramInfo.swapTotalMB/1024).toFixed(1) + " GB"}
                        ]
                        RowLayout {
                            Text {
                                text: modelData.name
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.color_a_text
                            }
                            Rectangle {Layout.fillWidth: true; Layout.preferredHeight: 2; color: Theme.color_3}
                            Text {
                                text: modelData.value
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.text_color_secondary
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: boardInfo
                anchors {
                    top: cpuInfo.bottom
                    right: parent.right
                    topMargin: 8
                }
                width: (parent.width / 2) - 4
                color: Theme.color_2
                height: colHyprInfo.implicitHeight + 20
                radius: 5
                ColumnLayout {
                    id: colHyprInfo
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Repeater {
                        model:[
                            { "name": "Board", "value": info.motherboard},
                            { "name": "Bios", "value": info.bios}
                        ]
                        RowLayout {
                            Text {
                                text: modelData.name
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.color_a_text
                            }
                            Rectangle {Layout.fillWidth: true; Layout.preferredHeight: 2; color: Theme.color_3}
                            Text {
                                text: modelData.value
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.text_color_secondary
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: gpuInfo
                anchors {
                    top: ramInfo.bottom
                    topMargin: 8
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width - 40
                color: Theme.color_2
                height: colGpuInfo.implicitHeight + 20
                radius: 5
                ColumnLayout {
                    id: colGpuInfo
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Repeater {
                        model:[
                            { "name": "GPU", "value": info.gpu},
                            { "name": "GPU Vendor", "value": info.gpuVendor}
                        ]
                        RowLayout {
                            Text {
                                text: modelData.name
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.color_a_text
                            }
                            Rectangle {Layout.fillWidth: true; Layout.preferredHeight: 2; color: Theme.color_3}
                            Text {
                                text: modelData.value
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.text_color_secondary
                            }
                        }
                    }
                }
            }
        }
    }
}
