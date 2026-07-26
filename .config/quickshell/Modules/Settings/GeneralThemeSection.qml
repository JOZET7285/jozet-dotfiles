import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: generalThemeSection
    ColumnLayout {
        spacing: 12
        Text { text: "Appearance"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        RowLayout {
            spacing: 10
            Text { text: "Theme:"; font.pixelSize: 12; color: Theme.text_color; Layout.preferredWidth: 100 }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                color: maDarkTheme.containsMouse ? Theme.dark_2_solid : Theme.dark_1_solid 
                Behavior on color { ColorAnimation { duration: 250 }}
                border { 
                    color: SystemManager.riceSettings.theme.mode === "dark" ? Theme.color_b_accent : Theme.color_3
                    width: 2 
                }
                MouseArea {
                    id: maDarkTheme
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: SystemManager.setSetting("theme.mode", "dark")
                }
            }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                color: maLightTheme.containsMouse ? Theme.light_2_solid : Theme.light_1_solid 
                Behavior on color { ColorAnimation { duration: 250 }}
                border { 
                    color: SystemManager.riceSettings.theme.mode === "light" ? Theme.color_b_accent : Theme.color_3
                    width: 2 
                }
                MouseArea {
                    id: maLightTheme
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: SystemManager.setSetting("theme.mode", "light")
                }
            }
        }
        RowLayout {
            spacing: 10
            Text { text: "Accent:"; font.pixelSize: 12; color: Theme.text_color; Layout.preferredWidth: 100 }
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
                    border {
                        color: Theme.accentKey === modelData.key ? "white" : "transparent"
                        width: 2
                    }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SystemManager.setSetting("theme.accent_color", modelData.key)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
} 