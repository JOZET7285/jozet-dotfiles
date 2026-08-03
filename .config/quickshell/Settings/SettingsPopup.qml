import Jozet.System 1.0
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

    function scanNetworks() {
        SystemManager.scanNetworks()
    }

    function forgetNetwork(ssid) {
        Quickshell.execDetached(["nmcli", "connection", "delete", ssid])
        SystemManager.scanNetworks()
    }

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
                { name: "Notifications", icon: "\uf0f3" },
                { name: "Monitors", icon: "\uf108" }
            ]
        },
        {
            config: "Theme",
            icon: "\uf1fc",
            sections: [
                { name: "General", icon: "\uf1fc" },
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
                0: [infoSection, energySection, audioSection],
                1: [networkSection, accessPointSection, bluetoothSection],
                2: [usbSection],
                3: [lockSection, notifySection, monitorsSection],
                4: [generalThemeSection, hyprlandSection, cursorSection]
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

            InfoSection { id: infoSection }
            EnergySection { id: energySection }
            AudioSection { id: audioSection }

            NetworkSection { id: networkSection }
            AccessPointSection { id: accessPointSection }
            BluetoothSection { id: bluetoothSection }

            UsbSection { id: usbSection }

            MonitorsSection { id: monitorsSection }
            LockScreenSection { id: lockSection }
            NotificationSection { id: notifySection }

            GeneralThemeSection { id: generalThemeSection; }

            Component {
                id: hyprlandSection
                ColumnLayout {
                    spacing: 12
                    Text { text: "Hyprland"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
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
                                    { key: "theme.hyprland.gaps_in", label: "Gaps In" },
                                    { key: "theme.hyprland.gaps_out", label: "Gaps Out" },
                                    { key: "theme.hyprland.border_radius", label: "Border Radius" },
                                    { key: "theme.hyprland.border_size", label: "Border Size" }
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
                                                var val = SystemManager.getSetting(modelData.key)
                                                if (val > 0) SystemManager.setSetting(modelData.key, val - 1)
                                                hyprlandIndicator.text = val - 1
                                            }
                                        }
                                        Text { anchors.centerIn: parent; text: "-"; color: Theme.text_color; font.pixelSize: 14 }
                                    }
                                    Text {
                                        id: hyprlandIndicator
                                        text: SystemManager.getSetting(modelData.key)
                                        font.pixelSize: 13; 
                                        color: Theme.text_color; 
                                        font.bold: true
                                        Layout.preferredWidth: 30; horizontalAlignment: Text.AlignHCenter
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 6
                                        color: Theme.color_3
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                var val = SystemManager.getSetting(modelData.key)
                                                SystemManager.setSetting(modelData.key, val + 1)
                                                hyprlandIndicator.text = val + 1
                                            }
                                        }
                                        Text { anchors.centerIn: parent; text: "+"; color: Theme.text_color; font.pixelSize: 14 }
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }

            Component {
                id: cursorSection
                CursorSection {}
            }
        }
    }
}
