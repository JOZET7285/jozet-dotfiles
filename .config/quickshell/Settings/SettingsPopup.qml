import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components/"
import "../Modules/Settings"

BasePopup {
    id: settingsPopup
    customWidth: 700
    property string screenName: modelData.name
    ipcTarget: "settings-"+screenName

    property int configIndex: 0
    property int sectionIndex: 0

    property var configs: [
        {
            config: "System",
            icon: "\uf013",
            sections: [
                { name: "Info", icon: "\uf129" },
                { name: "Energy", icon: "\uf0e7" },
                { name: "Audio", icon: "\uf028" }
            ]
        },
        {
            config: "Connections",
            icon: "\uf1eb",
            sections: [
                { name: "Network", icon: "\uf1eb" },
                { name: "Access Point", icon: "\uf0ac" },
                { name: "Bluetooth", icon: "\uf293" }
            ]
        },
        {
            config: "Devices",
            icon: "\uf287",
            sections: [
                { name: "USB", icon: "\uf287" }
            ]
        },
        {
            config: "Display",
            icon: "\uf108",
            sections: [
                { name: "LockScreen", icon: "\uf023" },
                { name: "Notifications", icon: "\uf0f3" }
            ]
        },
        {
            config: "Theme",
            icon: "\uf1fc",
            sections: [
                { name: "General", icon: "\uf53f" },
                { name: "Hyprland", icon: "\uf009" },
                { name: "Cursor", icon: "\uf245" }
            ]
        }
    ]

    popupContent: Component {
        Item {
            id: popupRoot
            implicitWidth: 680
            implicitHeight: 460

            property var sectionComponents: ({
                0: [systemSection, energySection, audioSection],
                1: [networkSection, accessPointSection, bluetoothSection],
                2: [usbSection],
                3: [lockSection, notifSection],
                4: [appearanceSection, hyprlandSection, cursorSection]
            })

            function currentSection() {
                var configSections = sectionComponents[settingsPopup.configIndex]
                if (!configSections || settingsPopup.sectionIndex >= configSections.length)
                    return null
                return configSections[settingsPopup.sectionIndex]
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    SideBar {}

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Theme.color_1
                        radius: 8

                        Loader {
                            anchors.fill: parent
                            anchors.margins: 15
                            sourceComponent: popupRoot.currentSection()
                        }
                    }
                }
            }

            // --- System ---
            SystemSection { id: systemSection }
            EnergySection { id: energySection }
            AudioSection { id: audioSection }

            // --- Connections ---
            NetworkSection { id: networkSection }
            AccessPointSection { id: accessPointSection }
            BluetoothSection { id: bluetoothSection }

            // --- Devices ---
            UsbSection { id: usbSection }

            // --- Display ---
            Component {
                id: lockSection
                ColumnLayout {
                    spacing: 12
                    Text { text: "Lock Screen"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }
                    RowLayout {
                        spacing: 10
                        Text { text: "Blur:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 100 }
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                            color: sysManager.getSetting("display.lockscreen.blur") ? Theme.color_g : Theme.color_3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var current = sysManager.getSetting("display.lockscreen.blur")
                                    sysManager.setSetting("display.lockscreen.blur", !current)
                                }
                            }
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                color: "white"
                                x: sysManager.getSetting("display.lockscreen.blur") ? 20 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on x { NumberAnimation { duration: 150 } }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            Component {
                id: notifSection
                ColumnLayout {
                    spacing: 12
                    Text { text: "Notificaciones"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }
                    RowLayout {
                        spacing: 10
                        Text { text: "No molestar:"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 100 }
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                            color: sysManager.getSetting("display.notifications.do_not_disturb") ? Theme.color_g : Theme.color_3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var current = sysManager.getSetting("display.notifications.do_not_disturb")
                                    sysManager.setSetting("display.notifications.do_not_disturb", !current)
                                }
                            }
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                color: "white"
                                x: sysManager.getSetting("display.notifications.do_not_disturb") ? 20 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on x { NumberAnimation { duration: 150 } }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            // --- Theme ---
            AppearanceSection { id: appearanceSection }

            Component {
                id: hyprlandSection
                ColumnLayout {
                    spacing: 12
                    Text { text: "Hyprland"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

                    Repeater {
                        model: [
                            { key: "theme.hyprland.gaps_in", label: "Gaps In" },
                            { key: "theme.hyprland.gaps_out", label: "Gaps Out" },
                            { key: "theme.hyprland.border_radius", label: "Border Radius" },
                            { key: "theme.hyprland.border_size", label: "Border Size" }
                        ]
                        RowLayout {
                            spacing: 10
                            Text { text: modelData.label + ":"; font.pixelSize: 12; color: Theme.color_b; Layout.preferredWidth: 100 }
                            Rectangle {
                                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6
                                color: Theme.color_3
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var val = sysManager.getSetting(modelData.key)
                                        if (val > 0) sysManager.setSetting(modelData.key, val - 1)
                                    }
                                }
                                Text { anchors.centerIn: parent; text: "-"; color: Theme.text_color; font.pixelSize: 14 }
                            }
                            Text {
                                text: sysManager.getSetting(modelData.key)
                                font.pixelSize: 13; color: Theme.text_color; font.bold: true
                                Layout.preferredWidth: 30; horizontalAlignment: Text.AlignHCenter
                            }
                            Rectangle {
                                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6
                                color: Theme.color_3
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var val = sysManager.getSetting(modelData.key)
                                        sysManager.setSetting(modelData.key, val + 1)
                                    }
                                }
                                Text { anchors.centerIn: parent; text: "+"; color: Theme.text_color; font.pixelSize: 14 }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            Component {
                id: cursorSection
                ColumnLayout {
                    spacing: 12
                    Text { text: "Cursor"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }
                    Text { text: "Próximamente"; font.pixelSize: 12; color: Theme.color_b }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
