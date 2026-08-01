import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

ColumnLayout {
    function fmtValue(v, step) {
        return step < 1 ? Number(v).toFixed(1) : String(Math.round(v))
    }

    spacing: 12
    Text { text: "Cursor"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 15
        Layout.rightMargin: 15
        color: Theme.color_2
        radius: 5
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            Repeater {
                model: [
                    { key: "theme.cursor.size", label: "Size", step: 1, min: 4, max: 128 },
                    { key: "theme.cursor.speed", label: "Speed", step: 0.1, min: -1.0, max: 1.0 }
                ]
                RowLayout {
                    spacing: 10
                    Text {
                        text: modelData.label + ":"
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                        Layout.preferredWidth: 100
                    }
                    Rectangle {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6
                        color: Theme.color_3
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var val = Number(SystemManager.getSetting(modelData.key))
                                if (val > modelData.min) {
                                    var nv = val - modelData.step
                                    if (modelData.step < 1) nv = Math.round(nv * 10) / 10
                                    SystemManager.setSetting(modelData.key, nv)
                                    cursorIndicator.text = fmtValue(nv, modelData.step)
                                }
                            }
                        }
                        Text { anchors.centerIn: parent; text: "-"; color: Theme.text_color; font.pixelSize: 14 }
                    }
                    Text {
                        id: cursorIndicator
                        text: fmtValue(SystemManager.getSetting(modelData.key), modelData.step)
                        font.pixelSize: 13
                        color: Theme.text_color
                        font.bold: true
                        Layout.preferredWidth: 34
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Rectangle {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6
                        color: Theme.color_3
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var val = Number(SystemManager.getSetting(modelData.key))
                                if (val < modelData.max) {
                                    var nv = val + modelData.step
                                    if (modelData.step < 1) nv = Math.round(nv * 10) / 10
                                    SystemManager.setSetting(modelData.key, nv)
                                    cursorIndicator.text = fmtValue(nv, modelData.step)
                                }
                            }
                        }
                        Text { anchors.centerIn: parent; text: "+"; color: Theme.text_color; font.pixelSize: 14 }
                    }
                }
            }
            RowLayout {
                Text {
                    text: "Cursor Theme"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.color_a_text
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "Refresh"
                    font.pixelSize: 12
                    background: Rectangle { color: Theme.color_3; radius: 6 }
                    onClicked: SystemManager.refreshCursors()
                }
            }
            GridView {
                id: cursorGrid
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                cellWidth: 80
                cellHeight: 80
                clip: true
                model: SystemManager.availableCursors
                property string selectedTheme: SystemManager.getSetting("theme.cursor.theme") || ""

                delegate: Item {
                    width: 80
                    height: 80
                    Rectangle {
                        id: cursorItem
                        anchors.fill: parent
                        color: Theme.color_3
                        radius: 6
                        anchors.margins: 5
                        border.color: modelData.name === cursorGrid.selectedTheme ? Theme.color_a_text : "transparent"
                        border.width: 2
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 5
                            Image {
                                source: modelData.preview || ""
                                fillMode: Image.PreserveAspectFit
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                cache: false
                                visible: modelData.preview && modelData.preview.length > 0
                            }
                            Text {
                                text: modelData.name
                                font.pixelSize: 12
                                color: Theme.text_color
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SystemManager.setSetting("theme.cursor.theme", modelData.name)
                                cursorGrid.selectedTheme = modelData.name
                            }
                        }
                    }
                }
            }
        }
    }
}
