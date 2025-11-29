pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: StateService.get("nightLight", false)
    
    property Process hyprsunsetProcess: Process {
        command: ["hyprsunset", "-t", "4000"]
        running: false
        stdout: SplitParser {
            onRead: (data) => {
                // hyprsunset output cuando está corriendo
                if (data) {
                    root.active = true
                }
            }
        }
        onStarted: {
            root.active = true
        }
        onExited: (code) => {
            root.active = false
        }
    }
    
    property Process killProcess: Process {
        command: ["pkill", "hyprsunset"]
        running: false
        onExited: (code) => {
            root.active = false
        }
    }
    
    property Process checkRunningProcess: Process {
        command: ["pgrep", "hyprsunset"]
        running: false
        onExited: (code) => {
            const isRunning = code === 0
            
            // If state says active but not running, start it
            if (root.active && !isRunning) {
                console.log("NightLightService: Starting hyprsunset (state was active but not running)")
                hyprsunsetProcess.running = true
            } 
            // If state says inactive but running, kill it
            else if (!root.active && isRunning) {
                console.log("NightLightService: Stopping hyprsunset (state was inactive but running)")
                killProcess.running = true
            }
        }
    }

    function toggle() {
        if (active) {
            killProcess.running = true
        } else {
            hyprsunsetProcess.running = true
        }
    }
    
    function syncState() {
        checkRunningProcess.running = true
    }

    onActiveChanged: {
        if (StateService.initialized) {
            StateService.set("nightLight", active);
        }
    }

    Connections {
        target: StateService
        function onStateLoaded() {
            root.active = StateService.get("nightLight", false);
            root.syncState();
        }
    }

    // Auto-initialize on creation
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            if (StateService.initialized) {
                root.active = StateService.get("nightLight", false);
                root.syncState();
            }
        }
    }
}
