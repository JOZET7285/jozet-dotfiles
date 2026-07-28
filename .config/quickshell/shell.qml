import Quickshell
import QtQuick
import Quickshell.Io
import "Islands"
import Jozet.System 1.0

ShellRoot {
    Component.onCompleted: SystemManager.scanBluetooth(true)

    IpcHandler {
        target: "session"
        function lock(): void {
            SystemManager.lockSession()
        }
    }
    Variants {
        model: Quickshell.screens
        Main { visible: !SystemManager.locked }
    }
    Variants {
        model: Quickshell.screens
        BottomHoverZone { visible: !SystemManager.locked }
    }
    Loader {
        active: SystemManager.locked
        sourceComponent: Component {
            Variants{ 
                model: Quickshell.screens
                LockScreen{}
            }
        }
    }
}
