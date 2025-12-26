import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.globals

QtObject {
    id: root

    signal screenshotCaptured(string path)
    signal errorOccurred(string message)
    signal windowListReady(var windows)

    property string tempPath: "/tmp/ambxst_freeze.png"
    property string cropPath: "/tmp/ambxst_crop.png"
    
    // We'll store the resolved XDG_PICTURES_DIR/Screenshots here
    property string screenshotsDir: ""
    property string finalPath: ""

    // Process to resolve XDG_PICTURES_DIR
    property Process xdgProcess: Process {
        id: xdgProcess
        command: ["bash", "-c", "xdg-user-dir PICTURES"]
        stdout: StdioCollector {
             onTextChanged: {
                // Not running immediately, handled in onExited
             }
        }
        running: true // Run on load
        onExited: exitCode => {
            if (exitCode === 0) {
                var dir = xdgProcess.stdout.text.trim()
                if (dir === "") {
                    // Fallback to home/Pictures if xdg-user-dir fails or returns empty
                    dir = Quickshell.env("HOME") + "/Pictures"
                }
                root.screenshotsDir = dir + "/Screenshots"
                // Ensure directory exists
                ensureDirProcess.running = true
            }
        }
    }

    property Process ensureDirProcess: Process {
        id: ensureDirProcess
        command: ["mkdir", "-p", root.screenshotsDir]
    }

    // Process for initial freeze
    property Process freezeProcess: Process {
        id: freezeProcess
        command: ["grim", root.tempPath]
        onExited: exitCode => {
            if (exitCode === 0) {
                root.screenshotCaptured(root.tempPath)
            } else {
                root.errorOccurred("Failed to capture screen (grim)")
            }
        }
    }

    // Process for fetching windows
    property Process clientsProcess: Process {
        id: clientsProcess
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector {}
        onExited: exitCode => {
            if (exitCode === 0) {
                try {
                    var allClients = JSON.parse(clientsProcess.stdout.text)
                    root.windowListReady(allClients)
                } catch (e) {
                    root.errorOccurred("Failed to parse window list: " + e.message)
                }
            }
        }
    }

    // Process for cropping/saving
    property Process cropProcess: Process {
        id: cropProcess
        // command set dynamically
        onExited: exitCode => {
            if (exitCode === 0) {
                // After successful save/crop, copy to clipboard
                copyProcess.running = true
            } else {
                root.errorOccurred("Failed to save image")
            }
        }
    }

    property Process copyProcess: Process {
        id: copyProcess
        command: ["bash", "-c", `wl-copy < "${root.finalPath}"`]
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("Failed to copy to clipboard")
            }
        }
    }

    function freezeScreen() {
        freezeProcess.running = true
    }

    function fetchWindows() {
        clientsProcess.running = true
    }

    function getTimestamp() {
        // Simple timestamp format YYYY-MM-DD-HH-mm-ss
        var d = new Date()
        // Manually format to avoid weird ISO chars
        var pad = (n) => n < 10 ? '0' + n : n;
        return d.getFullYear() + '-' + 
               pad(d.getMonth() + 1) + '-' + 
               pad(d.getDate()) + '-' + 
               pad(d.getHours()) + '-' + 
               pad(d.getMinutes()) + '-' + 
               pad(d.getSeconds());
    }

    function processRegion(x, y, w, h) {
        if (root.screenshotsDir === "") {
            // Fallback if xdg process hasn't finished yet?
             root.screenshotsDir = Quickshell.env("HOME") + "/Pictures/Screenshots"
        }
        
        var filename = "Screenshot_" + getTimestamp() + ".png"
        root.finalPath = root.screenshotsDir + "/" + filename
        
        // convert /tmp/ambxst_freeze.png -crop WxH+X+Y /path/to/save.png
        var geom = `${w}x${h}+${x}+${y}`
        cropProcess.command = ["convert", root.tempPath, "-crop", geom, root.finalPath]
        cropProcess.running = true
    }

    function processFullscreen() {
        if (root.screenshotsDir === "") {
             root.screenshotsDir = Quickshell.env("HOME") + "/Pictures/Screenshots"
        }
        
        var filename = "Screenshot_" + getTimestamp() + ".png"
        root.finalPath = root.screenshotsDir + "/" + filename

        // Just copy the freeze file to final path
        cropProcess.command = ["cp", root.tempPath, root.finalPath]
        cropProcess.running = true
    }
}
