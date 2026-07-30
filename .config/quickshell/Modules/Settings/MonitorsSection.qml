import Jozet.System 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../Components/"

Component {
    id: monitorsComponent

    ScrollView {
        id: scrollView
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        property var monitorsData: []

        Timer {
            id: refreshTimer
            interval: 500
            running: false
            onTriggered: scrollView.loadMonitors()
        }

        function loadMonitors() {
            try {
                var json = SystemManager.getMonitorsJson()
                if (!json) { console.log("MonitorsSection: empty JSON"); return }
                var parsed = JSON.parse(json)
                if (!parsed || parsed.length === 0) { console.log("MonitorsSection: no monitors"); return }

                var seenNames = {}
                var unique = []
                for (var i = 0; i < parsed.length; i++) {
                    var m = parsed[i]
                    var name = m.name || ""
                    if (seenNames[name]) continue
                    seenNames[name] = true

                    var modes = m.availableModes || []
                    var seenRes = {}
                    var resolutions = []
                    var rateMap = {}
                    for (var j = 0; j < modes.length; j++) {
                        var ms = modes[j]
                        if (typeof ms !== "string") continue
                        var parts = ms.split('@')
                        var res = parts[0], rate = parts[1] ? parts[1].replace('Hz', '') : ""
                        if (res && !seenRes[res]) { seenRes[res] = true; resolutions.push(res) }
                        if (res && rate) {
                            if (!rateMap[res]) rateMap[res] = []
                            rateMap[res].push(rate)
                        }
                    }
                    var currentRes = (m.width && m.height) ? m.width + "x" + m.height : ""

                    unique.push({
                        id: m.id,
                        name: m.name,
                        description: m.description,
                        width: m.width, height: m.height,
                        refreshRate: m.refreshRate,
                        scale: m.scale,
                        transform: m.transform,
                        disabled: m.disabled,
                        vrr: m.vrr,
                        _resolutions: resolutions,
                        _currentRes: currentRes,
                        _rateMap: rateMap
                    })
                }
                unique.sort(function(a, b) { return (a.id || 0) - (b.id || 0) })
                monitorsData = unique
                console.log("MonitorsSection: loaded", unique.length, "monitors, res count:", unique[0] ? unique[0]._resolutions.length : "N/A")
            } catch (e) {
                console.log("MonitorsSection: failed to parse:", e)
            }
        }

        function refreshDelayed() { refreshTimer.restart() }

        ColumnLayout {
            spacing: 10
            width: scrollView.availableWidth

            Component.onCompleted: scrollView.loadMonitors()

            Text { text: "Monitores"; font.pixelSize: 16; font.bold: true; color: Theme.text_color }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.color_3 }

            Repeater {
                model: scrollView.monitorsData.length
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    property int _idx: index
                    MonitorCard {
                        monitorData: scrollView.monitorsData[_idx]
                        onRefresh: scrollView.refreshDelayed
                    }
                }
            }

            Item { Layout.preferredHeight: 12 }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 28; radius: 8
                color: refreshAllBtn.containsMouse ? Theme.color_b : Theme.color_3
                Text {
                    anchors.centerIn: parent
                    text: "\uf021  Refresh Monitors"
                    font.pixelSize: 11; font.bold: true
                    color: refreshAllBtn.containsMouse ? Theme.text_color : Theme.color_b
                }
                MouseArea {
                    id: refreshAllBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: scrollView.loadMonitors()
                }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            Item { Layout.fillHeight: true }
        }
    }
}
