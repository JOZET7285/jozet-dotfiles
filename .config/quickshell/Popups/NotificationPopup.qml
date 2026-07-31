import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Layouts
import "../Components"
import Jozet.System 1.0

BasePopupBottom {
    id: notifPopup
    customWidth: 350
    customHeight: 500
    ipcTarget: "notificationPopup-" + modelData.name

    ListModel {
        id: notificationModel
    }

    Connections {
        target: SystemManager

        function onNotificationReceived() {
            if (SystemManager.doNotDisturb) return;

            let notif = SystemManager.latestNotification;
            notificationModel.insert(0, {
                "notifId": notif.id,
                "appName": notif.appName,
                "summary": notif.summary,
                "body": notif.body,
                "appIcon": notif.appIcon
            });
        }

        function onNotificationClosed(id) {
            for (let i = 0; i < notificationModel.count; i++) {
                if (notificationModel.get(i).notifId === id) {
                    notificationModel.remove(i, 1);
                    break;
                }
            }
        }
    }

    popupContent: Component {
        Item {
            id: content
            width: parent.width
            height: 420

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Notifications"
                        color: Theme.text_color
                        font.pixelSize: 15
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 70
                        height: 26
                        radius: 13
                        color: Theme.color_3
                        border {
                            width: 1
                            color: SystemManager.doNotDisturb ? Theme.color_a_text : Theme.color_3
                        }
                        Behavior on border.color { ColorAnimation { duration: 250 } }

                        Text {
                            anchors.centerIn: parent
                            text: SystemManager.doNotDisturb ? "DND On" : "DND Off"
                            color: SystemManager.doNotDisturb ? Theme.color_a_text : Theme.text_color
                            font.pixelSize: 11
                            font.bold: true
                            Behavior on color { ColorAnimation { duration: 250 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SystemManager.doNotDisturb = !SystemManager.doNotDisturb
                        }
                    }

                    Rectangle {
                        width: 70
                        height: 26
                        radius: 13
                        color: Theme.color_3

                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            color: Theme.text_color
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notificationModel.clear()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.color_3
                }

                ListView {
                    id: notifList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: notificationModel

                    delegate: Rectangle {
                        width: notifList.width
                        height: 72
                        radius: 12
                        color: Theme.color_2

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                width: 36
                                height: 36
                                radius: 8
                                color: Theme.color_3
                                visible: model.appIcon !== undefined && model.appIcon !== ""

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: (model.appIcon !== undefined && model.appIcon !== "") 
                                            ? Quickshell.iconPath(model.appIcon) 
                                            : ""           
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: model.summary !== undefined && model.summary !== "" ? model.summary : model.appName
                                    color: Theme.color_a_text
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.body
                                    color: Theme.text_color
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: "✕"
                                color: Theme.text_color_secondary
                                font.pixelSize: 14
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SystemManager.closeNotification(model.notifId)
                                        notificationModel.remove(index, 1)
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "No notifications"
                        color: Theme.text_color_secondary
                        font.pixelSize: 13
                        font.italic: true
                        visible: notifList.count === 0
                    }
                }
            }
        }
    }
}