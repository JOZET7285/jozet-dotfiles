import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls

Item {
    id: mainProcesses
    property string currentSongTitle: "Sin reproducción" 
    property bool playerState: false

    function refreshAll() {
        if (!songTitleProc.running) songTitleProc.restart()
    }

    function execute(cmd) {
        internalShell.exec({
            command: ["sh", "-c", cmd]
        })
    }
    
    Process {
        id: internalShell
    }
    Process {
        id: songTitleProc
        command: ["playerctl", "-F", "metadata", "--format", "{{title}}"]
        
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var newTitle = data.trim()
                if (currentSongTitle !== newTitle) {
                    currentSongTitle = newTitle
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: statusProc
        command: ["playerctl", "-F", "status"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var playerStats = data.trim()
                playerState = playerStats === "Playing" ? true : false
            }
        }
        Component.onCompleted: running = true
    }
}