import QtQuick
import Quickshell.Io

Item {
    id: networkProcesses
    property string ethernetStatus: ""
    property string ethernetConnection: ""
    property string wifiStatus: ""
    property string wifiConnection: ""
    property string networkUses: ""
    property string networkUseConnection: ""

    function refreshAll(){
        if(!netStatusProc.running){
            netStatusProc.running = true
        }

        if(ethernetStatus == "connected") {
            networkUses = "ethernet";
            networkUseConnection = ethernetConnection;
        }
        else if(wifiStatus == "connected") {
            networkUses = "wifi";
            networkUseConnection = wifiConnection;
        }
    }

    Process {
        id: netStatusProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var netstat = data.trim()
                if(netstat.split(":")[0] == "ethernet"){
                    ethernetStatus = netstat.split(":")[1]
                    ethernetConnection = netstat.split(":")[2]
                }
                else if(netstat.split(":")[0] == "wifi"){
                    wifiStatus = netstat.split(":")[1]
                    wifiConnection = netstat.split(":")[2]
                }
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: ethInfoProc
        command: ["nmcli"]
    }
}