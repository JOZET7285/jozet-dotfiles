import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Components/"

Component {
    id: systemSection
    ColumnLayout {
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "System Info"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
            Item { Layout.fillWidth: true }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

        Text { text: "System Info"; font.pixelSize: 14; font.bold: true; color: Theme.color_a_text; Layout.leftMargin: 20 }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 15; Layout.rightMargin: 15
            color: Theme.color_2; radius: 5
            ListView {
                anchors.fill: parent; anchors.margins: 6
                clip: true
                spacing: 4
                model: {
                var info = SystemManager.systemInfo;
                var items = [];
                var add = function(label, value, color) {
                    if (value) items.push({ label: label, value: value });
                };

                // General
                add("Hostname", info.hostname);
                add("User", info.username);
                add("OS", info.os);
                add("Kernel", info.kernel);
                add("Arch", info.arch);
                add("WM", info.wm);
                add("Protocol", info.protocol);
                add("Shell", info.shell);

                // Hardware
                add("CPU", info.cpu);
                add("CPU Freq", info.cpuFreq);
                add("CPU Cores", info.cpuCores);
                add("GPU", (info.gpuVendor ? info.gpuVendor + " " : "") + info.gpu);
                add("GPU Driver", info.gpuDriver);
                add("GPU Type", info.gpuType);

                // Memory
                add("RAM", info.ramUsed + " / " + info.ramTotal + "  (" + info.ramPercent + ")");

                // Disk
                if (info.diskRootTotal) add("Root (/)", info.diskRootUsed + " / " + info.diskRootTotal + "  [" + info.diskRootFs + "]");
                if (info.diskHomeTotal) add("Home (/home)", info.diskHomeUsed + " / " + info.diskHomeTotal + "  [" + info.diskHomeFs + "]");

                // Battery
                if (info.batteryCapacity) add("Battery", info.batteryCapacity + "% — " + info.batteryStatus);
                if (info.batteryModel) add("Battery Model", info.batteryModel);

                return items;
            }

            delegate: Rectangle {
                width: ListView.view.width
                height: 28
                color: Theme.color_2
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Text {
                        Layout.leftMargin: 20
                        text: modelData.label
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.text_color
                        opacity: 0.7
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 2; color: Theme.color_3}
                    Text {
                        Layout.rightMargin: 20
                        text: modelData.value
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.color_a_text
                        elide: Text.ElideRight
                    }
                }
            }

                ScrollBar.vertical: ScrollBar {
                    policy: parent.contentHeight > parent.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    width: 6
                    contentItem: Rectangle {
                        implicitWidth: 6; implicitHeight: 10; radius: 3
                        color: parent.pressed ? Theme.color_3 : Theme.text_color
                        opacity: 0.5
                    }
                    background: Rectangle { color: "transparent"; radius: 3 }
                }
            }
        }
    }
}
