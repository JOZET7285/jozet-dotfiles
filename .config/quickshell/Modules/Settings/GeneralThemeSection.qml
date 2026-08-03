import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: generalThemeSection
    ScrollView {
        id: control
        padding: 5 
        clip: true
        ColumnLayout {
            width: control.availableWidth
            Process {
                id: runMatugen
            }

            function regenerateMatugen(mode) {
                var wallpaper = SystemManager.riceSettings.theme.wallpaper_path
                if (!wallpaper) return

                runMatugen.command = ["sh", "-c",
                    "matugen image '" + wallpaper + "' -m " + mode + " -j hex --prefer darkness 2>/dev/null"
                ]
                runMatugen.running = true
            }

            property real panelSize: parseFloat(SystemManager.getSetting("theme.panel.size")) || 1.0

            spacing: 12
            Text { text: "Appearance"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

            Text { text: "Mode"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 15; Layout.rightMargin: 15
                implicitHeight: modeRow.implicitHeight + 20
                color: Theme.color_2; radius: 5
                clip: true
                RowLayout {
                    id: modeRow
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    anchors.margins: 10; spacing: 10
                    Text { text: "Theme:"; font.pixelSize: 12; color: Theme.text_color }
                    Rectangle {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                        color: maDarkTheme.containsMouse ? Theme.dark_2_solid : Theme.dark_1_solid
                        Behavior on color { ColorAnimation { duration: 250 }}
                        border { color: SystemManager.riceSettings.theme.mode === "dark" ? Theme.color_b_accent : Theme.color_3; width: 2 }
                        MouseArea {
                            id: maDarkTheme; anchors.fill: parent; hoverEnabled: true
                            onClicked: { SystemManager.setSetting("theme.mode", "dark"); regenerateMatugen("dark") }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                        color: maLightTheme.containsMouse ? Theme.light_2_solid : Theme.light_1_solid
                        Behavior on color { ColorAnimation { duration: 250 }}
                        border { color: SystemManager.riceSettings.theme.mode === "light" ? Theme.color_b_accent : Theme.color_3; width: 2 }
                        MouseArea {
                            id: maLightTheme; anchors.fill: parent; hoverEnabled: true
                            onClicked: { SystemManager.setSetting("theme.mode", "light"); regenerateMatugen("light") }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            Item { Layout.preferredHeight: 8 }

            Text { text: "Accent Color"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 15; Layout.rightMargin: 15
                implicitHeight: accentRow.implicitHeight + 20
                color: Theme.color_2
                radius: 5
                clip: true
                RowLayout {
                    id: accentRow
                    anchors {
                        top: parent.top 
                        left: parent.left
                        right: parent.right 
                    }
                    anchors.margins: 10; spacing: 8
                    Text { text: "Accent:"; font.pixelSize: 12; color: Theme.text_color }
                    Repeater {
                        model: [
                            { key: "b", color: Theme.color_b_solid },
                            { key: "p", color: Theme.color_p_solid },
                            { key: "g", color: Theme.color_g_solid },
                            { key: "y", color: Theme.color_y_solid },
                            { key: "o", color: Theme.color_o_solid },
                            { key: "r", color: Theme.color_r_solid },
                            { key: "bw", color: Theme.text_color },
                            { key: "m", color: Theme.color_matugen},
                        ]
                        Rectangle {
                            Layout.preferredWidth: 24; Layout.preferredHeight: 24; radius: 12
                            color: modelData.color
                            border { color: SystemManager.riceSettings.theme.accent_color === modelData.key ? "white" : "transparent"; width: 2 }
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: SystemManager.setSetting("theme.accent_color", modelData.key)
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            Item { Layout.preferredHeight: 8 }

            Text { text: "Principal Panel"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 15; Layout.rightMargin: 15
                implicitHeight: panelColumn.implicitHeight + 20
                color: Theme.color_2
                radius: 5
                clip: true
                
                ColumnLayout {
                    id: panelColumn
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: "Scale: "
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.color_a_text
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            color: decScale.containsMouse ? Theme.color_4 : Theme.color_3
                            radius: 2
                            Text {
                                anchors.centerIn: parent
                                text: "-"
                                font.pixelSize: 12
                                color: Theme.text_color   
                            }
                            MouseArea {
                                id: decScale; anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    var next = Math.round(Math.max(0.75, panelSize - 0.05) * 100) / 100
                                    panelSize = next
                                    SystemManager.setSetting("theme.panel.size", next)
                                }
                            }
                        }
                        Text {
                            id: sizeText
                            text: Math.round(Math.max(0.75, Math.min(1.25, panelSize)) * 100) + "%"
                            font.pixelSize: 12
                            color: Theme.text_color
                        }
                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            color: incScale.containsMouse ? Theme.color_4 : Theme.color_3
                            radius: 2
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 12
                                color: Theme.text_color   
                            }
                            MouseArea {
                                id: incScale; anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    var next = Math.round(Math.min(1.25, panelSize + 0.05) * 100) / 100
                                    panelSize = next
                                    SystemManager.setSetting("theme.panel.size", next)
                                }
                            }
                        }
                    }
                    RowLayout {
                        spacing: 10
                        Text {
                            text: "Compact:"
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.color_a_text
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                            color: Theme.color_1
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var value = SystemManager.getSetting("theme.panel.compact")
                                    SystemManager.setSetting("theme.panel.compact", !value)
                                    if(value) {
                                        compactIndicator.color = Theme.color_2
                                        compactIndicator.x = 2
                                    } else {
                                        compactIndicator.color = Theme.color_a_text
                                        compactIndicator.x = 20
                                    }
                                }
                            }
                            Rectangle {
                                id: compactIndicator
                                width: 18; height: 18; radius: 9
                                color: SystemManager.getSetting("theme.panel.compact") ? Theme.color_a_text : Theme.color_3
                                x: SystemManager.getSetting("theme.panel.compact") ? 20 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: window ? window.suggestCompact : false
                        text: "Sugerencia: activa Compact para aprovechar mejor tu pantalla"
                        font.pixelSize: 10
                        color: Theme.color_y_text
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        spacing: 10
                        Text {
                            text: "Floating Islands:"
                            Layout.fillWidth: true
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.color_a_text
                        }
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                            color: Theme.color_1
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var value = SystemManager.getSetting("theme.panel.floating")
                                    SystemManager.setSetting("theme.panel.floating", !value)
                                    if(value) {
                                        floatingIndicator.color = Theme.color_2
                                        floatingIndicator.x = 2
                                    } else {
                                        floatingIndicator.color = Theme.color_a_text
                                        floatingIndicator.x = 20
                                    }
                                }
                            }
                            Rectangle {
                                id: floatingIndicator
                                width: 18; height: 18; radius: 9
                                color: SystemManager.getSetting("theme.panel.floating") ? Theme.color_a_text : Theme.color_3
                                x: SystemManager.getSetting("theme.panel.floating") ? 20 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Text {
                            text: "Shiny Edge:"
                            Layout.fillWidth: true
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.color_a_text
                        }
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                            color: Theme.color_1
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var value = SystemManager.getSetting("theme.panel.shiny_edge")
                                    SystemManager.setSetting("theme.panel.shiny_edge", !value)
                                    if(value) {
                                        shinyIndicator.color = Theme.color_2
                                        shinyIndicator.x = 2
                                    } else {
                                        shinyIndicator.color = Theme.color_a_text
                                        shinyIndicator.x = 20
                                    }
                                }
                            }
                            Rectangle {
                                id: shinyIndicator
                                width: 18; height: 18; radius: 9
                                color: SystemManager.getSetting("theme.panel.shiny_edge") ? Theme.color_a_text : Theme.color_3
                                x: SystemManager.getSetting("theme.panel.shiny_edge") ? 20 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                    
                    RowLayout {
                        spacing: 8
                        Text {
                            text: "Rounded Corners:"
                            Layout.fillWidth: true
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.color_a_text
                        }
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                            color: Theme.color_1
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var value = SystemManager.getSetting("theme.panel.rounded_corners")
                                    SystemManager.setSetting("theme.panel.rounded_corners", !value)
                                    if(value) {
                                        roundedIndicator.color = Theme.color_2
                                        roundedIndicator.x = 2
                                    } else {
                                        roundedIndicator.color = Theme.color_a_text
                                        roundedIndicator.x = 20
                                    }
                                }
                            }
                            Rectangle {
                                id: roundedIndicator
                                width: 18; height: 18; radius: 9
                                color: SystemManager.getSetting("theme.panel.rounded_corners") ? Theme.color_a_text : Theme.color_3
                                x: SystemManager.getSetting("theme.panel.rounded_corners") ? 20 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Text {
                            text: "Always-Visible Monitoring:"
                            Layout.fillWidth: true
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.color_a_text
                        }
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                            color: Theme.color_1
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var value = SystemManager.getSetting("theme.panel.always_visible_monitoring")
                                    SystemManager.setSetting("theme.panel.always_visible_monitoring", !value)
                                    if(value) {
                                        monitoringIndicator.color = Theme.color_2
                                        monitoringIndicator.x = 2
                                    } else {
                                        monitoringIndicator.color = Theme.color_a_text
                                        monitoringIndicator.x = 20
                                    }
                                }
                            }
                            Rectangle {
                                id: monitoringIndicator
                                width: 18; height: 18; radius: 9
                                color: SystemManager.getSetting("theme.panel.always_visible_monitoring") ? Theme.color_a_text : Theme.color_3
                                x: SystemManager.getSetting("theme.panel.always_visible_monitoring") ? 20 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }
            }
        }
    }
    
} 