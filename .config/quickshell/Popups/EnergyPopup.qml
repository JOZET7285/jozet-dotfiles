import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Components"
import "../Modules/Energy"

BasePrincipalPopup {
    id: energyPopup
    popupName: "energy"

    popupContent: Component {
        Item {
            id: content
            width: parent.width
            height: 200
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                EnergyModule {
                }
                BrightnessModule {
                }
            }
        }
    }
}