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
    property var sysManager
    customWidth: 800
    ipcTarget: "diskPopup"
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
                    sysManager: diskPopup.sysManager
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2
                    color: Theme.color_3
                }
                PartitionsUsage {
                    id: partitionsUsageArea
                    sysManager: diskPopup.sysManager
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
                    sysManager: diskPopup.sysManager
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2
                    color: Theme.color_3
                }
                MaintenanceInfo {
                    id: maintenanceInfoArea
                    sysManager: diskPopup.sysManager
                }
            }
        }
    }
}
