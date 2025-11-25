import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config

Rectangle {
    id: root

    required property bool isActive
    required property string iconName
    required property string tooltipText
    signal clicked

    color: root.isActive ? Colors.primary : Colors.surfaceBright
    radius: root.isActive ? Config.roundness : Config.roundness * 1.25

    Behavior on color {
        enabled: Config.animDuration > 0
        ColorAnimation {
            duration: Config.animDuration / 2
            easing.type: Easing.OutQuart
        }
    }

    Behavior on radius {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 2
            easing.type: Easing.OutQuart
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.iconName
        color: root.isActive ? Colors.overPrimary : Colors.overBackground
        font.family: Icons.font
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            enabled: Config.animDuration > 0
            ColorAnimation {
                duration: Config.animDuration / 2
                easing.type: Easing.OutQuart
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()

        StyledToolTip {
            visible: parent.containsMouse
            tooltipText: root.tooltipText
        }
    }
}
