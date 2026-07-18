import Quickshell
import QtQuick
import Quickshell.Io
import "Islands"
import Jozet.System 1.0

ShellRoot {
    Variants {
        model: Quickshell.screens
        Main {
        }
    }
    Loader {
        active: sysManager.locked
        sourceComponent: Variants {
            model: Quickshell.screens
            LockScreen{}
        }
    }
}
