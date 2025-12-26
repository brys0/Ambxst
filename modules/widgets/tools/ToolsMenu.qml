import QtQuick
import qs.modules.components
import qs.modules.theme
import qs.modules.globals
import Quickshell.Io

ActionGrid {
    id: root

    signal itemSelected

    layout: "row"
    buttonSize: 48
    iconSize: 20
    spacing: 8

    actions: [
        {
            icon: Icons.camera,
            tooltip: "Screenshot",
            command: ""
        },
        {
            icon: Icons.screenshots,
            tooltip: "Open Screenshots",
            command: ""
        },
        {
            type: "separator"
        },
        {
            icon: Icons.recordScreen,
            tooltip: "Record Screen",
            command: ""
        },
        {
            icon: Icons.recordings,
            tooltip: "Open Recordings",
            command: ""
        },
        {
            type: "separator"
        },
        {
            icon: Icons.picker,
            tooltip: "Color Picker",
            command: ""
        },
        {
            icon: Icons.textT,
            tooltip: "OCR",
            command: ""
        },
        {
            icon: Icons.qrCode,
            tooltip: "QR Code",
            command: ""
        },
        {
            icon: Icons.webcam,
            tooltip: "Mirror",
            command: ""
        }
    ]

    onActionTriggered: action => {
        console.log("Tools action triggered:", action.tooltip);
        
        if (action.tooltip === "Screenshot") {
            GlobalStates.screenshotToolVisible = true
        }
        
        root.itemSelected();
    }
}
