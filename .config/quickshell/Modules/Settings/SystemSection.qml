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

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: {
                var info = sysManager.systemInfo;
                var items = [];
                var add = function(label, value, color) {
                    if (value) items.push({ label: label, value: value, accent: color || Theme.color_b });
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
                add("RAM", sysManager.ramInfo.usedMB + "MB / " + info.ramTotal + "  (" + sysManager.ramInfo.usagePercent + ")", Theme.color_g);

                // Disk
                if (info.diskRootTotal) add("Root (/)", info.diskRootUsed + " / " + info.diskRootTotal + "  [" + info.diskRootFs + "]", Theme.color_b);
                if (info.diskHomeTotal) add("Home (/home)", info.diskHomeUsed + " / " + info.diskHomeTotal + "  [" + info.diskHomeFs + "]", Theme.color_b);

                // Battery
                if (info.batteryCapacity) add("Battery", info.batteryCapacity + "% — " + info.batteryStatus, Theme.color_y);
                if (info.batteryModel) add("Battery Model", info.batteryModel);

                return items;
            }

            delegate: Rectangle {
                width: ListView.view.width
                height: 28
                color: "transparent"
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Text {
                        text: modelData.label
                        font.pixelSize: 12
                        color: Theme.text_color
                        Layout.preferredWidth: 120
                        opacity: 0.7
                    }
                    Text {
                        text: modelData.value
                        font.pixelSize: 12
                        font.bold: true
                        color: modelData.accent
                        Layout.fillWidth: true
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
                background: Rectangle { color: Theme.color_1; radius: 3 }
            }
        }
    }
}
