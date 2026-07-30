import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"
import "../Modules/AppLauncher"

BasePrincipalPopup{
    id: appLauncher

    property string searchQuery: ""
    property string currentMonitor: modelData.name

    width: 315
    anchors.top: leftLand.bottom
    anchors.left: leftLand.left
    anchors.leftMargin: 10

    popupName: "appLauncher"

    onOpenChanged: if (open) searchQuery = ""

    onOpened: searchAppField.forceActiveFocus()
    onClosed: appLauncher.forceActiveFocus()

    function closeLauncher() { appLauncher.open = false }
    function launch(app) {
        if (app && app.command && app.command.length > 0) {
            Quickshell.execDetached(app.command)
            appLauncher.closeLauncher()
        }
    }
    
    popupContent: Component {
        Item {
            width: appLauncher.width
            height: 560
            clip: true

            RowLayout {
                id: header
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 22

                Text {
                    text: "Applications"
                    color: Theme.text_color
                    font.pixelSize: 15
                    font.bold: true
                }
                Text {
                    text: appListModel.values.length + " result" + (appListModel.values.length === 1 ? "" : "s")
                    color: Theme.text_color_secondary
                    font.pixelSize: 12
                }
            }

            SearchWrapper { id: searchWrapper }

            AppGrid { 
                id: appGrid 
                
                model: ScriptModel {
                    id: appListModel
                    values: {
                        return [...DesktopEntries.applications.values]
                            .filter(function(app) {
                                return app.name && !app.noDisplay && app.name.toLowerCase().includes(appLauncher.searchQuery.toLowerCase())
                            })
                            .sort(function(a, b) { return a.name.localeCompare(b.name) })
                    }
                }
            }
            ColumnLayout {
                anchors.centerIn: parent
                visible: appListModel.values.length === 0
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\uf05e"
                    font.family: Theme.iconFont
                    font.pixelSize: 32
                    color: Theme.light_3
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No applications were found"
                    color: Theme.text_color_secondary
                    font.pixelSize: 13
                }
            }
        }
    }
}
