import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    height: 50

    WlrLayershell.namespace: "quickshell:notch"
    WlrLayershell.layer: WlrLayer.Top

    color: "transparent"

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8
        width: 200
        height: 34
        color: Colors.surface
        radius: 17

        Text {
            anchors.centerIn: parent
            text: `${Quickshell.env("USER")}@${Quickshell.env("HOSTNAME")}`
            color: Colors.foreground
            font.pixelSize: 13
        }
    }
}