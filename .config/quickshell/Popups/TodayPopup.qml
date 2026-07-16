import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Components/"
import "../Modules/Today"

BasePopup {
    id: todayPopup
    property var sysManager
    customWidth: 725
    ipcTarget: "todayPopup"

    popupContent: Component {

        ColumnLayout {
            id: mainLayout
            spacing: 10
            property int currentMonth: new Date().getMonth()
            property int currentYear: new Date().getFullYear()

            ListModel {
                id: calendarModel
            }

            function generateMonth(month, year) {
                calendarModel.clear();
                
                let firstDay = new Date(year, month, 1).getDay();
                firstDay = firstDay === 0 ? 6 : firstDay - 1; 
                
                let daysInMonth = new Date(year, month + 1, 0).getDate();
                let daysInPrevMonth = new Date(year, month, 0).getDate();
                
                for (let i = firstDay - 1; i >= 0; i--) {
                    calendarModel.append({
                        "dayText": (daysInPrevMonth - i).toString(),
                        "isCurrentMonth": false,
                        "isToday": false
                    });
                }
                
                let today = new Date();
                for (let i = 1; i <= daysInMonth; i++) {
                    let isToday = (i === today.getDate() && month === today.getMonth() && year === today.getFullYear());
                    calendarModel.append({
                        "dayText": i.toString(),
                        "isCurrentMonth": true,
                        "isToday": isToday
                    });
                }
                
                let totalCells = 42;
                let remaining = totalCells - calendarModel.count;
                for (let i = 1; i <= remaining; i++) {
                    calendarModel.append({
                        "dayText": i.toString(),
                        "isCurrentMonth": false,
                        "isToday": false
                    });
                }
            }

            Component.onCompleted: {
                generateMonth(currentMonth, currentYear);
            }
            RowLayout {
                Layout.preferredWidth: 600
                Layout.preferredHeight: 450
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.color_2
                    radius: 15
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            
                            Text {
                                text: rootUISys.currentTime
                                font.pixelSize: 44
                                font.bold: true
                                color: Theme.text_color
                            }
                            Text {
                                text: rootUISys.currentDate
                                font.pixelSize: 12
                                color: Theme.light_2
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.05; color: Theme.color_1 }
                                GradientStop { position: 0.95; color: Theme.color_1 }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                            RowLayout {
                                anchors.fill: parent
                                Repeater {
                                    model: ["L", "M", "M", "J", "V", "S", "D"]
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        horizontalAlignment: Text.AlignHCenter
                                        font.bold: true
                                        color: Theme.light_2
                                    }
                                }
                            }
                        }

                        GridLayout {
                            id: calendarGrid
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            columns: 7
                            rowSpacing: 10

                            Repeater {
                                model: calendarModel
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: width / 2.2
                                    color: model.isToday ? Theme.color_b : "transparent"
                                    radius: 5
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: model.dayText
                                        font.bold: model.isToday
                                        color: {
                                            if (model.isToday) return Theme.color_1; 
                                            if (!model.isCurrentMonth) return Theme.color_3;
                                            return Theme.text_color;
                                        }
                                    }
                                }
                            }

                        }

                        Events { id: eventsSection }
                    }
                }
                Agenda { id: agendaSection }
            }
            UserActivity { id: userActivitySection }
        }
    } 
}