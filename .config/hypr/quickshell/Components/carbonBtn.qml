// EnergyButton.qml
Rectangle {
    required property string text
    required property string profileName
    
    color: area.pressed || root.activeProfile == profileName ? "#3c3c3c" : "#2b2b2b"
    anchors.fill: parent
    border.color: Theme.border
    radius: Theme.borderRadius

    MouseArea {
        id: area
        anchors.fill: parent
        onClicked: root.setProfile(profileName)
    }
}