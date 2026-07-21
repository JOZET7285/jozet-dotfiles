import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: appearanceSection
    ColumnLayout {
        spacing: 12
        Text { text: "Apariencia"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        RowLayout {
            spacing: 10
            Text { text: "Tema:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 100 }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                color: Theme.color_1_solid; border { color: Theme.color_3; width: 2 }
            }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                color: "#f0f0f0"; border { color: Theme.color_3; width: 2 }
            }
        }
        RowLayout {
            spacing: 10
            Text { text: "Acento:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 100 }
            Repeater {
                model: [Theme.color_b_solid, Theme.color_p_solid, Theme.color_g_solid, Theme.color_y_solid, Theme.color_o_solid, Theme.color_r_solid]
                Rectangle {
                    Layout.preferredWidth: 24; Layout.preferredHeight: 24; radius: 12
                    color: modelData
                    border { color: "white"; width: 2 }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
} 