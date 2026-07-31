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

    width: 420 * scaleFactor
    anchors.top: leftLand.bottom
    anchors.left: leftLand.left
    anchors.leftMargin: 10

    popupName: "appLauncher"

    onOpenChanged: if (open) searchQuery = ""

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
            anchors.leftMargin: 5
            clip: true

            Connections {
                target: appLauncher
                function onOpened() {
                    searchWrapper.searchAppField.forceActiveFocus()
                }
            }

            RowLayout {
                id: header
                anchors.left: parent.left
                anchors.top: parent.top
                height: 22
                width: parent.width - 20

                Text {
                    text: "Applications"
                    color: Theme.text_color
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: appListModel.values.length + " result" + (appListModel.values.length === 1 ? "" : "s")
                    color: Theme.text_color_secondary
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: searchWrapper 
                color: Theme.color_2
                anchors.left: parent.left
                anchors.top: header.bottom
                height: 32
                width: parent.width - 20
                radius: 5
                clip: true
                anchors.topMargin: 10
                
                SearchWrapper { }
            }

            AppGrid { 
                id: appGrid 
                anchors {
                    left: parent.left
                    right: parent.right
                    top: searchWrapper.bottom
                    margins: 10
                    bottom: parent.bottom
                }
                
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
