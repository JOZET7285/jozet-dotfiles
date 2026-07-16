import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"

BasePopup {
    id: tempPopup
    customWidth: 300
    ipcTarget: "tempPopup"

    popupContent: Component {
        ColumnLayout {
            id: mainLayout
            spacing: 15
            Repeater {
                model: (sysManager.sensorTemperatures || []).slice(0, 5)

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26

                    Text {
                        text: modelData.name
                        color: {
                            if (modelData.temperature < 75) return Theme.text_color
                            if (modelData.temperature < 95) return Theme.color_o
                            return Theme.color_r
                        }
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }}
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: Theme.color_3
                    }
                    Text {
                        text: modelData.temperature + "°C"
                        color: {
                            if (modelData.temperature < 75) return Theme.text_color
                            if (modelData.temperature < 85) return Theme.color_o
                            return Theme.color_r
                        }
                        opacity: 0.6
                        font.pixelSize: 12
                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }}
                    }
                }
            }
        }
    }
}