import QtQuick
import QtQuick.Controls
import QtQuick.Effects
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
    color: root.selected ? Theme.btn_selected_color : (area.containsMouse ? Theme.btn_accent_color : Theme.btn_color)
    radius: root.selected ? Theme.radius : 8

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()

        ToolTip.visible: root.tooltipText.length > 0 && containsMouse
        ToolTip.text: root.tooltipText
        ToolTip.delay: 400
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
            color: Theme.btn_text_color
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: animatedText
            
            visible: root.text.length > 0
            text: _internalText
            horizontalAlignment: Text.AlignHCenter 
            verticalAlignment: Text.AlignVCenter
            color: Theme.btn_text_color
            font.family: Theme.fontName
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
}
