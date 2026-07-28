import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Components/"

GridLayout {
    id: gridContainer
    Layout.fillWidth: true
    Layout.preferredHeight: Math.min(gridRows * 60 + (gridRows - 1) * 10, 200)
    Layout.maximumHeight: 200

    columns: 3
    columnSpacing: 10
    rowSpacing: 10
    clip: true

    readonly property var availableList: SystemManager.availableBluetoothDevices.filter(d => !d.connected)
    readonly property int count: Math.min(availableList.length, 9)
    readonly property int gridRows: Math.ceil(count / 3)

    Repeater {
        model: gridContainer.count

        delegate: Button {
            property var device: gridContainer.availableList[index]
            property bool isConnecting: bluetoothPopup.connectingAddress === device.address

            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.minimumWidth: 80
            enabled: !isConnecting && bluetoothPopup.connectingAddress === ""

            contentItem: Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: isConnecting ? "Connecting..." : (device.name || "Unknown")
                    color: Theme.text_color
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    width: parent.width
                    elide: Text.ElideRight
                    font.pointSize: 9
                }

                BusyIndicator {
                    visible: isConnecting
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 20
                    height: 20
                }
            }

            background: Rectangle {
                color: isConnecting ? Theme.color_b : 
                    (parent.down ? Theme.color_2 : 
                    (parent.hovered ? Theme.color_3 : Theme.color_1_solid))
                border.color: isConnecting ? Theme.color_b : Theme.light_3
                border.width: isConnecting ? 2 : 1
                radius: 10
                opacity: enabled ? 1.0 : 0.5
            }

            onClicked: {
                if (!isConnecting) {
                    bluetoothPopup.connectingAddress = device.address
                    SystemManager.connectBluetooth(device.address)
                    connectionTimeout.start()
                }
            }
        }
    }

    Text {
        visible: gridContainer.count === 0
        text: "No devices availables"
        color: Theme.light_4
        font.italic: true
        Layout.columnSpan: 3
        Layout.alignment: Qt.AlignHCenter
    }
}