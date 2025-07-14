import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../theme"

Rectangle {
    id: root

    required property var bar

    height: parent.height
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: 32
    color: Colors.surfaceBright
    radius: 8

    RowLayout {
        id: rowLayout

        anchors.fill: parent
        spacing: 8
        anchors.margins: 4

        Repeater {
            model: SystemTray.items

            SysTrayItem {
                required property SystemTrayItem modelData

                bar: root.bar
                item: modelData
            }
        }
    }
}
