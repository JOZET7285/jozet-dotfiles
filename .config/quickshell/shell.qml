import Quickshell
import QtQuick
import Quickshell.Io
import "Islands"
import Jozet.System 1.0

ShellRoot {
    SystemManager {
        id: sysManager
        Component.onCompleted: {
            sysManager.scanBluetooth(true)
        }
    }
    IpcHandler {
        target: "session"
        function lock(): void {
            sysManager.lockSession()
        }
    }
    Variants {
        model: Quickshell.screens
        Main { visible: !sysManager.locked }
    }
    Loader {
        active: sysManager.locked
        sourceComponent: Component {
            Variants{ 
                model: Quickshell.screens
                LockScreen{}
            }
        }
    }
}
