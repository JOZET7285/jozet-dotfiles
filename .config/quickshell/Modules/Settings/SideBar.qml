import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Rectangle {
    id: sideBar
    Layout.preferredWidth: 160
    Layout.fillHeight: true
    color: Theme.color_2
    radius: 8

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2

        Repeater {
            model: settingsPopup.configs
            delegate: Rectangle {
                id: configItem
                property int configIdx: index
                property var itemSections: modelData.sections
                property bool isExpanded: settingsPopup.configIndex === index

                Layout.fillWidth: true
                Layout.preferredHeight: isExpanded ? 36 + (30 * itemSections.length) + 15 : 36
                radius: 6
                color: isExpanded
                        ? Theme.color_3 : "transparent"

                Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 150 } }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: modelData.icon
                                font.pixelSize: 14
                                color: configItem.isExpanded ? Theme.color_b : Theme.text_color
                            }
                            Text {
                                text: modelData.config
                                font.pixelSize: 12
                                font.bold: configItem.isExpanded
                                color: configItem.isExpanded ? Theme.color_b : Theme.text_color
                                Layout.fillWidth: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                settingsPopup.configIndex = index
                                settingsPopup.sectionIndex = 0
                            }
                        }
                    }
                    Repeater {
                        model: configItem.itemSections
                        delegate: Rectangle {
                            property bool isActive: settingsPopup.configIndex === configItem.configIdx
                                                    && settingsPopup.sectionIndex === index

                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            Layout.preferredHeight: 30
                            radius: 6
                            visible: settingsPopup.configIndex === configItem.configIdx
                            color: isActive
                                    ? Theme.color_2_solid : (sectionMa.containsMouse ? Theme.color_2 : "transparent")

                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 12
                                    color: isActive ? Theme.color_b : Theme.text_color
                                }
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 11
                                    font.bold: isActive
                                    color: isActive ? Theme.color_b : Theme.text_color
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                id: sectionMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    settingsPopup.configIndex = configItem.configIdx
                                    settingsPopup.sectionIndex = index
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
