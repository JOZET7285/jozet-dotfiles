import Quickshell
import QtQuick
import Quickshell.Io
import "Islands"

ShellRoot {
    Variants {
        model: Quickshell.screens.length > 0 ? [Quickshell.screens[0]] : []        
        Main {
        }
    }
}