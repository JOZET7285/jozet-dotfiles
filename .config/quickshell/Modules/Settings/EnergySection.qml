import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: energySection
    ColumnLayout {
        id: root
        spacing: 8
        readonly property var rs: SystemManager.riceSettings
        property string activeKey: SystemManager.getSetting("energy.active_profile") || "balanced"

        Connections {
            target: SystemManager
            function onRiceSettingsChanged() {
                root.activeKey = SystemManager.getSetting("energy.active_profile") || "balanced"
            }
        }

        function get(key) {
            var parts = key.split(".")
            var v = rs
            for (var i = 0; i < parts.length; i++) {
                if (v === undefined || v === null) return undefined
                v = v[parts[i]]
            }
            return v
        }

        Text { 
            text: "Energy"
            font.pixelSize: 16 
            font.bold: true
            color: Theme.text_color
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                Layout.leftMargin: 20
                text: "Battery:"
                font.pixelSize: 12
                color: Theme.text_color
                font.bold: true
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }
            Text {
                Layout.rightMargin: 20
                text: SystemManager.batteryCapacity + "% (" + SystemManager.batteryStatus + ")"
                font.pixelSize: 12
                color: Theme.text_color
            }
        }

        Item { Layout.preferredHeight: 8 }

        Text { 
            text: "Active Profile" 
            font.pixelSize: 14 
            font.bold: true 
            color: Theme.text_color 
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Repeater {
            model: [
                { key: "saver",    label: "Saver",     icon: "\uf06c",  sysProfile: "power-saver" },
                { key: "balanced", label: "Balanced",  icon: "\uf24e",  sysProfile: "balanced" },
                { key: "perform",  label: "Perform", icon: "\uf0e7",  sysProfile: "performance" }
            ]
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                height: 32
                radius: 6
                color: root.activeKey === modelData.key ? Theme.color_3 : "transparent"
                border.color: root.activeKey === modelData.key ? Theme.color_a_text : Theme.color_3
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 8

                    Text {
                        text: modelData.icon
                        font.pixelSize: 12
                        color: root.activeKey === modelData.key ? Theme.color_a_text : Theme.text_color
                    }
                    Text {
                        text: modelData.label
                        font.pixelSize: 12
                        font.bold: root.activeKey === modelData.key
                        color: root.activeKey === modelData.key ? Theme.color_a_text : Theme.text_color
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "Brightness: " + (root.get("energy.profiles." + modelData.key + ".brightness") || 0) + "%"
                        font.pixelSize: 11
                        color: Theme.text_color
                        opacity: 0.6
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        SystemManager.setSetting("energy.active_profile", modelData.key)
                        SystemManager.setPowerProfile(modelData.sysProfile)
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 8 }

        Text { 
            text: "Profile Settings" 
            font.pixelSize: 14
            font.bold: true 
            color: Theme.text_color 
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            spacing: 10
            Text { 
                text: "Brightness:" 
                font.pixelSize: 12 
                color: Theme.text_color 
                Layout.preferredWidth: 120 
            }
            Slider {
                Layout.fillWidth: true
                id: brightnessSlider
                from: 5; to: 100; stepSize: 1

                function sync() {
                    value = root.get("energy.profiles." + root.activeKey + ".brightness") || 80
                }
                Connections {
                    target: root
                    function onActiveKeyChanged() { brightnessSlider.sync() }
                    function onRsChanged() { brightnessSlider.sync() }
                }
                Component.onCompleted: sync()
                value: root.get("energy.profiles." + root.activeKey + ".brightness") || 80
                onMoved: SystemManager.setBrightnessPersist(Math.round(value))
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
            Text { 
                text: brightnessSlider.value.toFixed(0) + "%" 
                font.pixelSize: 12
                color: Theme.text_color
                Layout.preferredWidth: 35
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            spacing: 10
            Text { 
                text: "Display:"
                font.pixelSize: 12
                color: Theme.text_color 
                Layout.preferredWidth: 120 
            }
            Rectangle {
                Layout.preferredWidth: 28 
                Layout.preferredHeight: 28 
                radius: 6 
                color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = SystemManager.getSetting("energy.profiles." + root.activeKey + ".screen_timeout_min") || 5
                        if (v > 1) SystemManager.setSetting("energy.profiles." + root.activeKey + ".screen_timeout_min", v - 1)
                    }
                }
                Text { 
                    anchors.centerIn: parent 
                    text: "-"
                    color: Theme.text_color 
                    font.pixelSize: 14 
                }
            }
            Text {
                text: (SystemManager.getSetting("energy.profiles." + root.activeKey + ".screen_timeout_min") || 5) + " min"
                font.pixelSize: 12 
                color: Theme.text_color 
                font.bold: true
                Layout.preferredWidth: 50 
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6; color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = SystemManager.getSetting("energy.profiles." + root.activeKey + ".screen_timeout_min") || 5
                        SystemManager.setSetting("energy.profiles." + root.activeKey + ".screen_timeout_min", v + 1)
                    }
                }
                Text { anchors.centerIn: parent; text: "+"; color: Theme.text_color; font.pixelSize: 14 }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            spacing: 10
            Text { text: "Suspend:"; font.pixelSize: 12; color: Theme.text_color; Layout.preferredWidth: 120 }
            Rectangle {
                Layout.preferredWidth: 28 
                Layout.preferredHeight: 28 
                radius: 6 
                color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = SystemManager.getSetting("energy.profiles." + root.activeKey + ".suspend_timeout_min") || 15
                        if (v > 1) SystemManager.setSetting("energy.profiles." + root.activeKey + ".suspend_timeout_min", v - 1)
                    }
                }
                Text { anchors.centerIn: parent; text: "-"; color: Theme.text_color; font.pixelSize: 14 }
            }
            Text {
                text: (SystemManager.getSetting("energy.profiles." + root.activeKey + ".suspend_timeout_min") || 15) + " min"
                font.pixelSize: 12; color: Theme.text_color; font.bold: true
                Layout.preferredWidth: 50; horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6; color: Theme.color_3
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var v = SystemManager.getSetting("energy.profiles." + root.activeKey + ".suspend_timeout_min") || 15
                        SystemManager.setSetting("energy.profiles." + root.activeKey + ".suspend_timeout_min", v + 1)
                    }
                }
                Text { anchors.centerIn: parent; text: "+"; color: Theme.text_color; font.pixelSize: 14 }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
