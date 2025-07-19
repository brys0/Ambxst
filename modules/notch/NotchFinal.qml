import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../workspaces"
import "../launcher"

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    height: notchContainer.height + 16

    WlrLayershell.namespace: "quickshell:notch"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: GlobalStates.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"

    // Default view component - user@host text
    Component {
        id: defaultViewComponent
        Item {
            width: userHostText.implicitWidth + 24
            height: 28

            Text {
                id: userHostText
                anchors.centerIn: parent
                text: `${Quickshell.env("USER")}@${Quickshell.env("HOSTNAME")}`
                color: Colors.foreground
                font.pixelSize: 13
                font.weight: Font.Medium
            }
        }
    }

    // Launcher view component - custom sized launcher
    Component {
        id: launcherViewComponent
        Item {
            width: 480
            height: Math.min(launcherSearch.implicitHeight, 400)

            LauncherSearch {
                id: launcherSearch
                anchors.fill: parent
                
                onItemSelected: {
                    GlobalStates.launcherOpen = false
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.launcherOpen = false
                        event.accepted = true
                    }
                }

                Component.onCompleted: {
                    clearSearch()
                    // Force focus on the search input
                    Qt.callLater(() => {
                        forceActiveFocus()
                    })
                }
            }
        }
    }

    // Apple-style notch container
    Rectangle {
        id: notchContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8
        
        width: Math.max(stackContainer.width + 32, 140)
        height: stackContainer.height + 20
        
        color: Colors.surface
        radius: Math.min(width / 8, height / 2)

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        // Subtle shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            color: "#15000000"
            radius: parent.radius
            z: -1
        }

        Item {
            id: stackContainer
            anchors.centerIn: parent
            width: stackView.currentItem ? stackView.currentItem.width : 0
            height: stackView.currentItem ? stackView.currentItem.height : 0

            StackView {
                id: stackView
                anchors.fill: parent
                initialItem: defaultViewComponent

                pushEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuart
                    }
                    PropertyAnimation {
                        property: "scale"
                        from: 0.95
                        to: 1
                        duration: 250
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                }

                pushExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 200
                        easing.type: Easing.OutQuart
                    }
                    PropertyAnimation {
                        property: "scale"
                        from: 1
                        to: 1.05
                        duration: 200
                        easing.type: Easing.OutQuart
                    }
                }

                popEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuart
                    }
                    PropertyAnimation {
                        property: "scale"
                        from: 1.05
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuart
                    }
                }

                popExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 200
                        easing.type: Easing.OutQuart
                    }
                    PropertyAnimation {
                        property: "scale"
                        from: 1
                        to: 0.95
                        duration: 200
                        easing.type: Easing.OutQuart
                    }
                }
            }
        }
    }

    // Listen for launcher state changes
    Connections {
        target: GlobalStates
        function onLauncherOpenChanged() {
            if (GlobalStates.launcherOpen) {
                stackView.push(launcherViewComponent)
                // Ensure keyboard focus
                Qt.callLater(() => {
                    root.requestActivate()
                    root.forceActiveFocus()
                })
            } else {
                if (stackView.depth > 1) {
                    stackView.pop()
                }
            }
        }
    }

    // Handle global keyboard events
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape && GlobalStates.launcherOpen) {
            GlobalStates.launcherOpen = false
            event.accepted = true
        }
    }
}