import Quickshell
import QtQuick
import Quickshell.Io
import "Islands"

ShellRoot {
    Variants {
        model: Quickshell.screens
        Main {
        }
    }
    Variants {
        model: Quickshell.screens
        LockScreen{}
    }
}