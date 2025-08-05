import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.modules.workspaces
import qs.modules.theme
import qs.modules.clock
import qs.modules.systray
import qs.modules.launcher
import qs.modules.corners
import qs.config

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
        // bottom: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    exclusiveZone: Config.bar.showBackground ? 44 : 40
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 44 + Config.roundness + 4
    mask: Region {
        width: panel.width
        height: 44
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: 44

        property color bgcolor: Qt.rgba(Qt.color(Colors.background).r, Qt.color(Colors.background).g, Qt.color(Colors.background).b, 0.5)

        color: Config.bar.showBackground ? bgcolor : "transparent"

        RoundCorner {
            id: topLeft
            size: Config.roundness > 0 ? Config.roundness + 4 : 0
            anchors.left: parent.left
            anchors.top: parent.bottom
            corner: RoundCorner.CornerEnum.TopLeft
            color: parent.color
        }

        RoundCorner {
            id: topRight
            size: Config.roundness > 0 ? Config.roundness + 4 : 0
            anchors.right: parent.right
            anchors.top: parent.bottom
            corner: RoundCorner.CornerEnum.TopRight
            color: parent.color
        }

        // Left side of bar
        RowLayout {
            id: leftSide
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 4
            spacing: 4

            LauncherButton {
                id: launcherButton
            }

            Workspaces {
                bar: QtObject {
                    property var screen: panel.screen
                }
            }

            OverviewButton {
                id: overviewButton
            }
        }

        // Right side of bar
        RowLayout {
            id: rightSide
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            spacing: 4

            SysTray {
                bar: panel
            }

            Clock {
                id: clockComponent
            }
        }
    }
}
