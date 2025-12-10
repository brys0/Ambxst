pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.widgets.dashboard.controls
import qs.config

FloatingWindow {
    id: root

    visible: GlobalStates.settingsVisible
    title: "Ambxst Settings"
    color: "transparent"

    minimumSize: Qt.size(750, 750)
    maximumSize: Qt.size(750, 750)

    Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.surfaceContainerLowest
        radius: Styling.radius(0)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Title bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: Colors.surfaceContainer
                radius: Styling.radius(-1)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    // Title
                    Text {
                        text: "Ambxst Settings"
                        font.family: Styling.defaultFont
                        font.pixelSize: Styling.fontSize(0) + 2
                        font.bold: true
                        color: Colors.primary
                        Layout.fillWidth: true
                    }

                    // Unsaved indicator
                    Text {
                        visible: GlobalStates.themeHasChanges
                        text: "Unsaved changes"
                        font.family: Styling.defaultFont
                        font.pixelSize: Styling.fontSize(0)
                        color: Colors.error
                        opacity: 0.8
                    }

                    // Discard button
                    Button {
                        id: discardButton
                        enabled: GlobalStates.themeHasChanges
                        Layout.preferredHeight: 32
                        leftPadding: 12
                        rightPadding: 12

                        background: Rectangle {
                            color: GlobalStates.themeHasChanges ? Colors.error : Colors.surfaceContainer
                            radius: Styling.radius(-4)
                            opacity: GlobalStates.themeHasChanges ? (discardButton.hovered ? 0.8 : 1.0) : 0.5
                        }

                        contentItem: RowLayout {
                            spacing: 6

                            Text {
                                text: Icons.sync
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: GlobalStates.themeHasChanges ? Colors.overError : Colors.overBackground
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: "Discard"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: GlobalStates.themeHasChanges ? Colors.overError : Colors.overBackground
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        onClicked: GlobalStates.discardThemeChanges()

                        ToolTip.visible: hovered
                        ToolTip.text: "Discard all changes"
                        ToolTip.delay: 500
                    }

                    // Apply button
                    Button {
                        id: applyButton
                        Layout.preferredHeight: 32
                        leftPadding: 12
                        rightPadding: 12

                        background: Rectangle {
                            color: GlobalStates.themeHasChanges ? Colors.primary : Colors.surfaceContainer
                            radius: Styling.radius(-4)
                            opacity: GlobalStates.themeHasChanges ? (applyButton.hovered ? 0.8 : 1.0) : 0.5
                        }

                        contentItem: RowLayout {
                            spacing: 6

                            Text {
                                text: Icons.disk
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: GlobalStates.themeHasChanges ? Colors.overPrimary : Colors.overBackground
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: "Apply"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: GlobalStates.themeHasChanges ? Colors.overPrimary : Colors.overBackground
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        onClicked: GlobalStates.applyThemeChanges()

                        ToolTip.visible: hovered
                        ToolTip.text: "Save changes to config"
                        ToolTip.delay: 500
                    }

                    // Close button
                    Button {
                        id: titleCloseButton
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32

                        background: Rectangle {
                            color: titleCloseButton.hovered ? Colors.overErrorContainer : Colors.error
                            radius: Styling.radius(-4)
                        }

                        contentItem: Text {
                            text: Icons.cancel
                            font.family: Icons.font
                            font.pixelSize: 18
                            color: titleCloseButton.hovered ? Colors.error : Colors.overError
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (GlobalStates.themeHasChanges) {
                                GlobalStates.discardThemeChanges();
                            }
                            GlobalStates.settingsVisible = false;
                        }
                    }
                }
            }

            // Main content
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                // Left side: Vertical tabs
                Rectangle {
                    id: tabsContainer
                    Layout.preferredWidth: 160
                    Layout.fillHeight: true
                    color: Colors.surfaceContainer
                    radius: Styling.radius(-1)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Text {
                            text: "Settings"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(0)
                            font.bold: true
                            color: Colors.primary
                            Layout.alignment: Qt.AlignHCenter
                            Layout.bottomMargin: 8
                        }

                        Repeater {
                            model: [
                                {
                                    name: "Theme",
                                    icon: Icons.cube
                                },
                                {
                                    name: "Bar",
                                    icon: Icons.gear
                                },
                                {
                                    name: "Hyprland",
                                    icon: Icons.gear
                                }
                            ]

                            delegate: Button {
                                id: tabButton
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                Layout.preferredHeight: 40

                                readonly property bool isSelected: tabStack.currentIndex === index

                                background: Rectangle {
                                    color: tabButton.isSelected ? Colors.primary : (tabButton.hovered ? Colors.surfaceContainerHigh : Colors.surfaceContainer)
                                    radius: Styling.radius(-2)

                                    Behavior on color {
                                        enabled: (Config.animDuration ?? 0) > 0
                                        ColorAnimation {
                                            duration: (Config.animDuration ?? 0) / 2
                                        }
                                    }
                                }

                                contentItem: RowLayout {
                                    spacing: 8

                                    Text {
                                        text: tabButton.modelData.icon
                                        font.family: Icons.font
                                        font.pixelSize: 18
                                        color: tabButton.isSelected ? Colors.overPrimary : Colors.overBackground
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: tabButton.modelData.name
                                        font.family: Styling.defaultFont
                                        font.pixelSize: Styling.fontSize(0)
                                        color: tabButton.isSelected ? Colors.overPrimary : Colors.overBackground
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }

                                onClicked: tabStack.currentIndex = index
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                // Right side: Content area
                StackLayout {
                    id: tabStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: 0

                    // Theme tab
                    ThemePanel {
                        id: themeTab
                    }

                    // Bar tab (placeholder)
                    Rectangle {
                        color: Colors.surfaceContainer
                        radius: Styling.radius(-1)

                        Text {
                            anchors.centerIn: parent
                            text: "Bar Settings (Coming Soon)"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(0)
                            color: Colors.overBackground
                        }
                    }

                    // Hyprland tab (placeholder)
                    Rectangle {
                        color: Colors.surfaceContainer
                        radius: Styling.radius(-1)

                        Text {
                            anchors.centerIn: parent
                            text: "Hyprland Settings (Coming Soon)"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(0)
                            color: Colors.overBackground
                        }
                    }
                }
            }
        }
    }
}
