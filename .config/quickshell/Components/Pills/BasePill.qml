import QtQuick
import QtQuick.Controls
import ".."

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property string tooltipText: ""
    property bool selected: false
    

    signal clicked()

    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: Theme.height - 6

    color: selected ? Theme.bg_1 : (area.containsMouse ? Theme.bg_hover : Theme.bg_2)
    radius: 8

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.icon.length > 0 && root.text.length > 0 ? 6 : 0

        Text {
            visible: root.icon.length > 0
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: 15
            color: root.selected ? Theme.accent : Theme.text_color
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: animatedText
            
            visible: root.text.length > 0
            
            text: _internalText
            
            horizontalAlignment: Text.AlignHCenter 
            verticalAlignment: Text.AlignVCenter
            color: root.selected ? Theme.accent : Theme.text_color
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter

            property string _internalText: root.text

            SequentialAnimation {
                id: textChangeAnimation
                
                NumberAnimation { 
                    target: animatedText
                    property: "opacity"
                    to: 0
                    duration: 150 
                    easing.type: Easing.InOutQuad
                }
                
                PropertyAction { 
                    target: animatedText
                    property: "_internalText"
                    value: root.text 
                }
                
                // 3. Muestra el nuevo texto fluidamente
                NumberAnimation { 
                    target: animatedText
                    property: "opacity"
                    to: 1
                    duration: 150 
                    easing.type: Easing.InOutQuad
                }
            }

            Connections {
                target: root
                function onTextChanged() {
                    if (animatedText._internalText === root.text) return;
                    
                    if (animatedText._internalText === "") {
                        animatedText._internalText = root.text;
                        return;
                    }

                    textChangeAnimation.restart();
                }
            }
        }

    }

    ToolTip {
        visible: root.tooltipText.length > 0 && area.containsMouse
        text: root.tooltipText
        delay: 400
    }
}
