import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components/"

Rectangle {
    id: root
    required property var monitorData
    required property var onRefresh

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + 24
    color: Theme.color_2
    radius: 8
    clip: true

    function applyConfig(resolution, rate, transform, scale) {
        SystemManager.applyMonitorConfig(monitorData.name, resolution, rate || Math.round(monitorData.refreshRate).toString(), transform || 0, scale || 1)
        onRefresh()
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: (monitorData.name || "") + " (" + (monitorData.description || "").split(' ').slice(0,3).join(' ') + ")"
                font.pixelSize: 13; font.bold: true
                color: Theme.text_color; Layout.fillWidth: true; elide: Text.ElideRight
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 6
            Text { 
                text: "Resolution:" 
                font.pixelSize: 11
                font.bold: true
                color: Theme.color_a_text
                Layout.preferredWidth: 80 
            }

            ComboBox {
                id: resCombo
                Layout.fillWidth: true 
                Layout.preferredHeight: 26
                model: monitorData._resolutions || []
                
                popup: Popup {
                    y: resCombo.height
                    width: resCombo.width 
                    implicitHeight: Math.min(contentItem.contentHeight, 100)
                    topPadding: 1
                    bottomPadding: 1
                    leftPadding: 0
                    rightPadding: 0

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: resCombo.popup.visible ? resCombo.delegateModel : null
                        ScrollIndicator.vertical: ScrollIndicator { } 
                    }
                    
                    background: Rectangle {
                        color: Theme.color_1_solid
                        radius: 6
                        border.color: Theme.color_3
                        border.width: 1
                    }
                }

                currentIndex: {
                    var cur = monitorData._currentRes || ""
                    var mdl = monitorData._resolutions || []
                    for (var i = 0; i < mdl.length; i++)
                        if (mdl[i] === cur) return i
                    return -1
                }

                onActivated: {
                    rateCombo.model = monitorData._rateMap[monitorData._resolutions[currentIndex]] || []
                    rateCombo.currentIndex = 0
                }

                delegate: ItemDelegate { 
                    width: resCombo.width 
                    height: 26
                    text: modelData || ""
                    font.pixelSize: 11 
                    
                    contentItem: Text {
                        text: modelData || ""
                        font.pixelSize: 11 
                        color: Theme.text_color
                        verticalAlignment: Text.AlignVCenter 
                        leftPadding: 8
                    }
                    
                    background: Rectangle { 
                        color: highlighted ? Theme.color_3 : Theme.color_1_solid
                        radius: 6 
                    }
                }
                
                contentItem: Text {
                    text: resCombo.displayText
                    font.pixelSize: 11
                    color: Theme.text_color
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }
                
                background: Rectangle { 
                    color: Theme.color_1_solid 
                    radius: 6 
                    border.color: Theme.color_3 
                    border.width: 1 
                }
            }


            Rectangle {
                Layout.preferredWidth: 50; Layout.preferredHeight: 22; radius: 4
                color: applyResBtn.containsMouse ? Theme.color_b : Theme.color_3
                Text {
                    anchors.centerIn: parent; text: "Apply"; font.pixelSize: 10; font.bold: true
                    color: applyResBtn.containsMouse ? Theme.text_color : Theme.color_b
                }
                MouseArea {
                    id: applyResBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var res = resCombo.model[resCombo.currentIndex]
                        var rate = rateCombo.model[rateCombo.currentIndex]
                        if (res) applyConfig(res, rate || Math.round(monitorData.refreshRate).toString(), monitorData.transform, monitorData.scale)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 6
            Text { 
                text: "Hertz:"
                font.pixelSize: 11 
                font.bold: true
                color: Theme.color_a_text
                Layout.preferredWidth: 80 
            }
            ComboBox {
                id: rateCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                model: monitorData._rateMap[monitorData._currentRes || ""] || []
                
                popup: Popup {
                    y: rateCombo.height
                    width: rateCombo.width 
                    implicitHeight: Math.min(contentItem.contentHeight, 100)
                    topPadding: 1
                    bottomPadding: 1
                    leftPadding: 0
                    rightPadding: 0

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: rateCombo.popup.visible ? rateCombo.delegateModel : null
                        ScrollIndicator.vertical: ScrollIndicator { } 
                    }
                    
                    background: Rectangle {
                        color: Theme.color_1_solid
                        radius: 6
                        border.color: Theme.color_3
                        border.width: 1
                    }
                }

                currentIndex: {
                    var rates = monitorData._rateMap[monitorData._currentRes || ""] || []
                    var curRate = Math.round(monitorData.refreshRate).toString()
                    for (var i = 0; i < rates.length; i++)
                        if (rates[i].indexOf(curRate) >= 0) return i
                    return 0
                }

                delegate: ItemDelegate { 
                    width: rateCombo.width
                    height: 26
                    text: modelData ? modelData + " Hz" : ""
                    font.pixelSize: 11 
                    
                    contentItem: Text {
                        text: modelData ? modelData + " Hz" : ""
                        font.pixelSize: 11 
                        color: Theme.text_color
                        verticalAlignment: Text.AlignVCenter 
                        leftPadding: 8
                    }
                    
                    background: Rectangle { 
                        color: highlighted ? Theme.color_3 : Theme.color_1_solid
                        radius: 6 
                    }
                }

                contentItem: Text {
                    text: (rateCombo.currentIndex >= 0 && rateCombo.model && rateCombo.model[rateCombo.currentIndex])
                        ? rateCombo.model[rateCombo.currentIndex] + " Hz" : "-"
                    font.pixelSize: 11
                    color: Theme.text_color
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }

                background: Rectangle { 
                    color: Theme.color_1_solid 
                    radius: 6 
                    border.color: Theme.color_3 
                    border.width: 1 
                }
            }

            Item { Layout.preferredWidth: 50 }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 10
            Text { 
                text: "Enabled:"
                font.pixelSize: 11
                font.bold: true
                color: Theme.color_a_text
                Layout.preferredWidth: 80 
            }
            Rectangle {
                Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                color: monitorData.disabled === false ? Theme.color_g : Theme.color_3
                Rectangle {
                    width: 18; height: 18; radius: 9; color: Theme.text_color
                    anchors.verticalCenter: parent.verticalCenter
                    x: monitorData.disabled === false ? 20 : 2
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        SystemManager.setMonitorEnabled(monitorData.name, monitorData.disabled !== false)
                        onRefresh()
                    }
                }
            }
            Text { 
                text: "VRR:"
                font.pixelSize: 11
                font.bold: true
                color: Theme.color_a_text
                Layout.leftMargin: 20 
            }
            Rectangle {
                Layout.preferredWidth: 40; Layout.preferredHeight: 22; radius: 11
                color: monitorData.vrr === true ? Theme.color_g : Theme.color_3
                Rectangle {
                    width: 18; height: 18; radius: 9; color: Theme.text_color
                    anchors.verticalCenter: parent.verticalCenter
                    x: monitorData.vrr === true ? 20 : 2
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        SystemManager.setMonitorVrr(monitorData.name, monitorData.vrr !== true)
                        onRefresh()
                    }
                }
            }
        }
    }
}
