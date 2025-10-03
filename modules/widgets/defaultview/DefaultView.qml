import QtQuick
import qs.modules.theme
import qs.config

Item {
    implicitWidth: userInfo.implicitWidth + separator1.implicitWidth + placeholder.width + separator2.implicitWidth + notifIndicator.implicitWidth + 32
    implicitHeight: 40

    Row {
        anchors.centerIn: parent
        spacing: 8

        UserInfo {
            id: userInfo
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: separator1
            anchors.verticalCenter: parent.verticalCenter
            text: "•"
            color: Colors.outline
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }

        Rectangle {
            id: placeholder
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            height: 32
            radius: Math.max(0, Config.roundness - 4)
            color: Colors.surfaceBright
        }

        Text {
            id: separator2
            anchors.verticalCenter: parent.verticalCenter
            text: "•"
            color: Colors.outline
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }

        NotificationIndicator {
            id: notifIndicator
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
