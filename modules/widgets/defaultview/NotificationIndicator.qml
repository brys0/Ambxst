import QtQuick
import qs.modules.theme
import qs.modules.services
import qs.config

Item {
    implicitWidth: 24
    implicitHeight: 24

    Item {
        anchors.centerIn: parent
        width: 24
        height: 24

        Text {
            anchors.centerIn: parent
            text: Icons.bell
            font.family: Icons.font
            font.pixelSize: 20
            color: Colors.overBackground
        }

        Rectangle {
            visible: Notifications.list.length > 0
            anchors.right: parent.right
            anchors.top: parent.top
            width: 8
            height: 8
            radius: 4
            color: Colors.error
        }
    }
}
