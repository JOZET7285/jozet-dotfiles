import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: energySection
    ColumnLayout {
        spacing: 8

        // force re-evaluation of all bindings when riceSettings changes
        property var _settings: sysManager.riceSettings
        property string activeKey: sysManager.getSetting("energy.active_profile") || "balanced"

        Text { text: "Energía"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        // Battery info
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Batería:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 120 }
            Text { text: sysManager.batteryCapacity + "% (" + sysManager.batteryStatus + ")"; font.pixelSize: 12; color: Theme.text_color }
        }

        Item { Layout.preferredHeight: 8 }

        // Active profile selector
        Text { text: "Perfil activo"; font.pixelSize: 14; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Repeater {
            model: [
                { key: "saver",    label: "Ahorro",    icon: "\uf0e7" },
                { key: "balanced", label: "Balanceado", icon: "\uf0e7" },
                { key: "perform",  label: "Rendimiento", icon: "\uf0e7" }
            ]
            delegate: Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 6
                color: parent.parent.activeKey === modelData.key ? Theme.color_3 : "transparent"
                border.color: parent.parent.activeKey === modelData.key ? Theme.color_b : Theme.color_3
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: modelData.icon
                        font.pixelSize: 12
                        color: parent.parent.parent.activeKey === modelData.key ? Theme.color_b : Theme.text_color
                    }
                    Text {
                        text: modelData.label
                        font.pixelSize: 12
                        font.bold: parent.parent.parent.activeKey === modelData.key
                        color: parent.parent.parent.activeKey === modelData.key ? Theme.color_b : Theme.text_color
                        Layout.fillWidth: true
                    }
                    Text {
                        text: sysManager.getSetting("energy.profiles." + modelData.key + ".brightness") + "%"
                        font.pixelSize: 11
                        color: Theme.text_color
                        opacity: 0.6
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sysManager.setSetting("energy.active_profile", modelData.key)
                }
            }
        }

        Item { Layout.preferredHeight: 8 }

        // Profile settings for active profile
        Text { text: "Ajustes del perfil"; font.pixelSize: 14; font.bold: true; color: Theme.text_color }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        // Brightness
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Brillo:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 120 }
            Slider {
                Layout.fillWidth: true
                id: brightnessSlider
                from: 5; to: 100; stepSize: 1
                value: sysManager.getSetting("energy.profiles." + activeKey + ".brightness") || 80
                onMoved: sysManager.setSetting("energy.profiles." + activeKey + ".brightness", Math.round(value))
                background: Rectangle {
                    x: brightnessSlider.leftPadding
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                    implicitHeight: 6; implicitWidth: brightnessSlider.availableWidth
                    height: implicitHeight; radius: 3; color: Theme.color_3
                    Rectangle {
                        width: brightnessSlider.visualPosition * parent.width
                        height: parent.height; color: Theme.color_y; radius: 3
                    }
                }
                handle: Rectangle {
                    x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                    implicitWidth: 12; implicitHeight: 12; radius: 6
                    color: brightnessSlider.pressed ? Theme.color_y_solid : Theme.color_y
                }
            }
            Text { text: (sysManager.getSetting("energy.profiles." + activeKey + ".brightness") || 80) + "%"; font.pixelSize: 12; color: Theme.text_color; Layout.preferredWidth: 35 }
        }

        // Screen timeout
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Pantalla:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 120 }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6; color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = sysManager.getSetting("energy.profiles." + activeKey + ".screen_timeout_min") || 5
                        if (v > 1) sysManager.setSetting("energy.profiles." + activeKey + ".screen_timeout_min", v - 1)
                    }
                }
                Text { anchors.centerIn: parent; text: "-"; color: Theme.text_color; font.pixelSize: 14 }
            }
            Text {
                text: (sysManager.getSetting("energy.profiles." + activeKey + ".screen_timeout_min") || 5) + " min"
                font.pixelSize: 12; color: Theme.text_color; font.bold: true
                Layout.preferredWidth: 50; horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6; color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = sysManager.getSetting("energy.profiles." + activeKey + ".screen_timeout_min") || 5
                        sysManager.setSetting("energy.profiles." + activeKey + ".screen_timeout_min", v + 1)
                    }
                }
                Text { anchors.centerIn: parent; text: "+"; color: Theme.text_color; font.pixelSize: 14 }
            }
        }

        // Suspend timeout
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Suspensión:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 120 }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6; color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = sysManager.getSetting("energy.profiles." + activeKey + ".suspend_timeout_min") || 15
                        if (v > 1) sysManager.setSetting("energy.profiles." + activeKey + ".suspend_timeout_min", v - 1)
                    }
                }
                Text { anchors.centerIn: parent; text: "-"; color: Theme.text_color; font.pixelSize: 14 }
            }
            Text {
                text: (sysManager.getSetting("energy.profiles." + activeKey + ".suspend_timeout_min") || 15) + " min"
                font.pixelSize: 12; color: Theme.text_color; font.bold: true
                Layout.preferredWidth: 50; horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6; color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = sysManager.getSetting("energy.profiles." + activeKey + ".suspend_timeout_min") || 15
                        sysManager.setSetting("energy.profiles." + activeKey + ".suspend_timeout_min", v + 1)
                    }
                }
                Text { anchors.centerIn: parent; text: "+"; color: Theme.text_color; font.pixelSize: 14 }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
