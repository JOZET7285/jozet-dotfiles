import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import QtQuick 2.15 

Item {
    id: mainProcesses
    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0
    property int cpuTemp: 0
    property string currentSongTitle: "Sin reproducción" 
    property bool playerState: false
    property string netStatus: "Desconectado"

    function refreshAll() {
        if (!memProc.running) memProc.running = true
        if (!cpuProc.running) cpuProc.running = true
        if (!diskProc.running) diskProc.running = true
        if (!tempProc.running) tempProc.running = true
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
        id: netProc
        command: ["sh", "-c", "IFACE=$(ip route | grep default | awk '{for(i=1;i<=NF;i++) if($i==\"dev\") print $(i+1)}'); \ 
                            if [ -z \"$IFACE\" ]; then echo 'Desconectado'; \
                            elif [[ \"$IFACE\" == e* ]]; then echo 'Ethernet'; \
                            else echo 'Wi-Fi'; fi"]
        
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                netStatus = data.trim()
            }
        }
        Component.onCompleted: running = true
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

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                
                // Cálculo del porcentaje de RAM utilizada
                ramUsage = Math.round(100 * used / total)
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "top -b -n 1 -d 0.2 | grep '%Cpu' | tail -1 | awk '{print int(100 - $8)}'"]
        stdout: SplitParser {
            onRead: data => {
                var val = parseInt(data.trim())
                if (!isNaN(val)) cpuUsage = val
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: diskProc
        command: ["sh", "-c", "df /home | awk 'NR==2 {sub(/%/, \"\", $5); print $5}'"]
        
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parsed = parseInt(data.trim())
                if (!isNaN(parsed)) {
                    diskUsage = parsed
                }
            }
        }
    }
    Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp | awk '{print int($1/1000)}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var cleanData = data.trim()
                var parsed = parseInt(cleanData)
                if (!isNaN(parsed)) {
                    cpuTemp = parsed 
                }
            }
        }
        Component.onCompleted: running = true
    }
}