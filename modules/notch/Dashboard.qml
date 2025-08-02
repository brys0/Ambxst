import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.globals

Item {
    id: root

    property var state: QtObject {
        property int currentTab: 0
    }

    readonly property real nonAnimWidth: 400 + viewWrapper.anchors.margins * 2

    implicitWidth: nonAnimWidth
    implicitHeight: tabs.implicitHeight + tabs.anchors.topMargin + 300 + viewWrapper.anchors.margins * 2

    // Tab buttons
    Row {
        id: tabs

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 16
        anchors.margins: 20

        spacing: 8

        Repeater {
            model: ["Widgets", "Pins", "Kanban", "Wallpapers"]

            Button {
                required property int index
                required property string modelData

                text: modelData
                flat: true

                background: Rectangle {
                    color: root.state.currentTab === index ? Colors.adapter.primary : "transparent"
                    radius: 8
                    border.color: Colors.adapter.outline
                    border.width: root.state.currentTab === index ? 0 : 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    color: root.state.currentTab === index ? Colors.adapter.onPrimary : Colors.adapter.onSurface
                    font.family: Styling.defaultFont
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                onClicked: root.state.currentTab = index

                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }

                states: State {
                    name: "pressed"
                    when: parent.pressed
                    PropertyChanges {
                        target: parent
                        scale: 0.95
                    }
                }
            }
        }
    }

    // Content area
    Rectangle {
        id: viewWrapper

        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        anchors.topMargin: 12

        radius: 12
        color: Colors.adapter.surfaceContainer
        clip: true

        layer.enabled: true
        layer.samples: 4

        SwipeView {
            id: view

            anchors.fill: parent
            
            currentIndex: root.state.currentTab
            
            implicitWidth: 400
            implicitHeight: 300

            onCurrentIndexChanged: {
                root.state.currentTab = currentIndex
            }

            // Overview Tab
            DashboardPane {
                sourceComponent: overviewComponent
            }

            // System Tab  
            DashboardPane {
                sourceComponent: systemComponent
            }

            // Quick Settings Tab
            DashboardPane {
                sourceComponent: quickSettingsComponent
            }

            // Wallpapers Tab
            DashboardPane {
                sourceComponent: wallpapersComponent
            }
        }
    }

    // Animated size properties for smooth transitions
    property real animatedWidth: implicitWidth
    property real animatedHeight: implicitHeight
    
    width: animatedWidth
    height: animatedHeight
    
    // Update animated properties when implicit properties change
    onImplicitWidthChanged: animatedWidth = implicitWidth
    onImplicitHeightChanged: animatedHeight = implicitHeight

    Behavior on animatedWidth {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
    }

    Behavior on animatedHeight {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
    }

    // Component definitions for better performance (defined once, reused)
    Component {
        id: overviewComponent
        OverviewTab {}
    }

    Component {
        id: systemComponent
        SystemTab {}
    }

    Component {
        id: quickSettingsComponent
        QuickSettingsTab {}
    }

    Component {
        id: wallpapersComponent
        WallpapersTab {}
    }

    component DashboardPane: Item {
        implicitWidth: 400
        implicitHeight: 300
        
        property alias sourceComponent: loader.sourceComponent

        Loader {
            id: loader
            anchors.fill: parent
            active: true // Simplificamos: siempre cargar para debugging
        }
    }

    component OverviewTab: Rectangle {
        color: "transparent"
        implicitWidth: 400
        implicitHeight: 300

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Date and Time with live updates
            Column {
                width: parent.width
                spacing: 4

                property var currentTime: new Date()

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.currentTime = new Date()
                }

                Text {
                    text: Qt.formatDateTime(parent.currentTime, "dddd, MMMM d")
                    color: Colors.adapter.onSurface
                    font.family: Styling.defaultFont
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }

                Text {
                    text: Qt.formatDateTime(parent.currentTime, "h:mm AP")
                    color: Colors.adapter.onSurfaceVariant
                    font.family: Styling.defaultFont
                    font.pixelSize: 14
                }
            }

            // User Info
            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    color: Colors.adapter.primary

                    Text {
                        anchors.centerIn: parent
                        text: Quickshell.env("USER").charAt(0).toUpperCase()
                        color: Colors.adapter.onPrimary
                        font.family: Styling.defaultFont
                        font.pixelSize: 20
                        font.weight: Font.Bold
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: Quickshell.env("USER")
                        color: Colors.adapter.onSurface
                        font.family: Styling.defaultFont
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }

                    Text {
                        text: Quickshell.env("HOSTNAME")
                        color: Colors.adapter.onSurfaceVariant
                        font.family: Styling.defaultFont
                        font.pixelSize: 12
                    }
                }
            }

            // Workspaces preview
            Rectangle {
                width: parent.width
                height: 60
                radius: 8
                color: Colors.adapter.surface
                border.color: Colors.adapter.outline
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: parent.color = Colors.adapter.surfaceContainerHigh
                    onExited: parent.color = Colors.adapter.surface
                }

                Text {
                    anchors.centerIn: parent
                    text: "Workspaces"
                    color: Colors.adapter.onSurfaceVariant
                    font.family: Styling.defaultFont
                    font.pixelSize: 12
                }
            }
        }
    }

    component SystemTab: Rectangle {
        color: "transparent"
        implicitWidth: 400
        implicitHeight: 300

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "System Resources"
                color: Colors.adapter.onSurface
                font.family: Styling.defaultFont
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            // CPU Usage placeholder
            SystemCard {
                title: "CPU Usage"
                subtitle: "4 cores • 2.4 GHz"
            }

            // Memory Usage placeholder
            SystemCard {
                title: "Memory Usage"
                subtitle: "8 GB available"
            }

            // Storage placeholder
            SystemCard {
                title: "Storage"
                subtitle: "256 GB SSD"
            }
        }
    }

    component QuickSettingsTab: Rectangle {
        color: "transparent"
        implicitWidth: 400
        implicitHeight: 300

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Quick Settings"
                color: Colors.adapter.onSurface
                font.family: Styling.defaultFont
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            Grid {
                width: parent.width
                columns: 2
                spacing: 8

                Repeater {
                    model: ["WiFi", "Bluetooth", "Night Light", "Do Not Disturb"]

                    QuickSettingCard {
                        title: modelData
                    }
                }
            }
        }
    }

    component SystemCard: Rectangle {
        property string title: ""
        property string subtitle: ""

        width: parent.width
        height: 60
        radius: 8
        color: Colors.adapter.surface
        border.color: Colors.adapter.outline
        border.width: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: parent.color = Colors.adapter.surfaceContainerHigh
            onExited: parent.color = Colors.adapter.surface
        }

        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: parent.title
                color: Colors.adapter.onSurface
                font.family: Styling.defaultFont
                font.pixelSize: 12
                font.weight: Font.Medium
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: parent.subtitle
                color: Colors.adapter.onSurfaceVariant
                font.family: Styling.defaultFont
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    component QuickSettingCard: Rectangle {
        property string title: ""

        width: (parent.width - parent.spacing) / 2
        height: 60
        radius: 8
        color: Colors.adapter.surface
        border.color: Colors.adapter.outline
        border.width: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: parent.color = Colors.adapter.surfaceContainerHigh
            onExited: parent.color = Colors.adapter.surface
            onPressed: parent.scale = 0.95
            onReleased: parent.scale = 1.0
        }

        Text {
            anchors.centerIn: parent
            text: parent.title
            color: Colors.adapter.onSurfaceVariant
            font.family: Styling.defaultFont
            font.pixelSize: 12
            font.weight: Font.Medium
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
    }

    component WallpapersTab: Rectangle {
        color: "transparent"
        implicitWidth: 400
        implicitHeight: 300

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Wallpapers"
                color: Colors.adapter.onSurface
                font.family: Styling.defaultFont
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            ScrollView {
                width: parent.width
                height: parent.height - parent.children[0].height - parent.spacing

                GridView {
                    id: wallpaperGrid
                    cellWidth: 120
                    cellHeight: 90
                    model: GlobalStates.wallpaperManager ? GlobalStates.wallpaperManager.wallpaperPaths : []

                    delegate: Rectangle {
                        width: wallpaperGrid.cellWidth - 8
                        height: wallpaperGrid.cellHeight - 8
                        radius: 8
                        color: Colors.adapter.surface
                        border.color: isCurrentWallpaper ? Colors.adapter.primary : Colors.adapter.outline
                        border.width: isCurrentWallpaper ? 2 : 1

                        property bool isCurrentWallpaper: GlobalStates.wallpaperManager && 
                            GlobalStates.wallpaperManager.currentIndex === index

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            clip: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: 4
                                border.color: parent.parent.isCurrentWallpaper ? Colors.adapter.primary : "transparent"
                                border.width: 1
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                if (!parent.isCurrentWallpaper) {
                                    parent.color = Colors.adapter.surfaceContainerHigh;
                                }
                            }
                            onExited: {
                                if (!parent.isCurrentWallpaper) {
                                    parent.color = Colors.adapter.surface;
                                }
                            }
                            onPressed: parent.scale = 0.95
                            onReleased: parent.scale = 1.0

                            onClicked: {
                                if (GlobalStates.wallpaperManager) {
                                    GlobalStates.wallpaperManager.setWallpaperByIndex(index);
                                }
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
