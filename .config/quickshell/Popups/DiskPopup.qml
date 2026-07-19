import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"
import "../Modules/Disk"

BasePopup {
    id: diskPopup
    customWidth: 800
    
    onOpenChanged: {
        if (open && sysManager) {
            sysManager.refreshDiskStats()
        }
    }

    popupContent: Component {
        ColumnLayout {
            id: mainLayout
            spacing: 15

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                spacing: 10

                FoldersUsage {
                    id: foldersUsageArea
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2
                    color: Theme.color_3
                }
                PartitionsUsage {
                    id: partitionsUsageArea
                }
            }
            Rectangle {
                Layout.preferredHeight: 2
                Layout.fillWidth: true
                color: Theme.color_3
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                spacing: 10
                HealthDisk {
                    id: healthDiskArea
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2
                    color: Theme.color_3
                }
                MaintenanceInfo {
                    id: maintenanceInfoArea
                }
            }
        }
    }
}
