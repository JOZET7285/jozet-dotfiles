import QtQuick
import QtQuick.Layouts
import Quickshell
import Jozet.System 1.0
import "../Components"

Item {
    id: toastRoot

    property int toastWidth: 340
    property int toastDisplayTime: 5000
    property int maxToasts: 5

    width: toastWidth
    height: list.height

    ListModel { id: toastModel }

    Connections {
        target: SystemManager

        function onNotificationReceived() {
            if (SystemManager.doNotDisturb) return;

            if (toastModel.count >= maxToasts)
                toastModel.remove(toastModel.count - 1, 1);

            const notif = SystemManager.latestNotification;
            toastModel.append({
                "toastKey": Date.now().toString() + "-" + toastModel.count,
                "notifId": notif.id,
                "appName": notif.appName,
                "appIcon": notif.appIcon,
                "summary": notif.summary,
                "body": notif.body
            });
        }

        function onNotificationClosed(id) {
            for (let i = toastModel.count - 1; i >= 0; i--) {
                if (toastModel.get(i).notifId === id)
                    toastModel.remove(i, 1);
            }
        }

        function onDoNotDisturbChanged() {
            if (SystemManager.doNotDisturb)
                toastModel.clear();
        }
    }

    Column {
        id: list
        anchors.top: parent.top
        spacing: 8
        width: parent.width

        Repeater {
            model: toastModel

            delegate: Rectangle {
                id: card
                required property var model
                required property int index

                width: toastRoot.toastWidth
                height: 68
                radius: 12
                color: Theme.color_1_solid
                border.color: Theme.color_3_solid
                border.width: 1

                property bool dismissing: false
                property bool hovered: false
                property bool closeAfterDismiss: false
                property int nid: model.notifId

                opacity: dismissing ? 0 : 1
                y: dismissing ? -8 : 0

                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.InCubic } }

                HoverHandler {
                    onHoveredChanged: card.hovered = hovered
                }

                Timer {
                    id: dismissTimer
                    interval: toastRoot.toastDisplayTime
                    repeat: false
                    running: !card.dismissing && !card.hovered
                    onTriggered: card.startDismiss(false)
                }

                Timer {
                    id: finishTimer
                    interval: 240
                    repeat: false
                    onTriggered: {
                        for (let i = toastModel.count - 1; i >= 0; i--) {
                            if (toastModel.get(i).toastKey === card.model.toastKey) {
                                toastModel.remove(i, 1);
                                break;
                            }
                        }
                        if (card.closeAfterDismiss)
                            SystemManager.closeNotification(card.nid);
                    }
                }

                function startDismiss(closeNotif) {
                    if (dismissing) return;
                    closeAfterDismiss = closeNotif;
                    dismissing = true;
                    dismissTimer.stop();
                    finishTimer.start();
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: parent.height - 20
                    radius: 2
                    color: Theme.color_a_text
                }

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
                            anchors.margins: 5
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
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        text: "✕"
                        color: Theme.text_color_secondary
                        font.pixelSize: 13

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: card.startDismiss(true)
                        }
                    }
                }
            }
        }
    }
}
