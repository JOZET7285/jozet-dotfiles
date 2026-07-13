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

    implicitWidth: contentRow.implicitWidth * scaleFactor + 20
    implicitHeight: 38 * scaleFactor
    color: (root.selected ? Theme.color_3 : (area.containsMouse ? Theme.color_3 : "transparent"))
    radius: 8

    Behavior on color { 
        ColorAnimation { 
            duration: 150 
        } 
    }

    Behavior on border.color { 
        ColorAnimation { 
            duration: 120 
        } 
    }

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
            color: Theme.text_color
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: animatedText
            
            visible: root.text.length > 0
            text: _internalText
            horizontalAlignment: Text.AlignHCenter 
            verticalAlignment: Text.AlignVCenter
            color: Theme.color_b
            font.family: Theme.fontName
            font.pixelSize: 12
            font.bold: true
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
