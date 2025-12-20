pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import "../../widgets/dashboard/widgets"

Item {
    id: root

    property string currentTime: ""
    property string currentDayAbbrev: ""
    property string currentHours: ""
    property string currentMinutes: ""
    property string currentFullDate: ""

    required property var bar
    property bool vertical: bar.orientation === "vertical"
    property bool isHovered: false
    property bool layerEnabled: true

    // Popup visibility state
    property bool popupOpen: clockPopup.isOpen

    // Weather availability
    readonly property bool weatherAvailable: WeatherService.dataAvailable

    Layout.preferredWidth: vertical ? 36 : buttonBg.implicitWidth
    Layout.preferredHeight: vertical ? buttonBg.implicitHeight : 36

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    // Main button
    StyledRect {
        id: buttonBg
        variant: root.popupOpen ? "primary" : "bg"
        anchors.fill: parent
        enableShadow: root.layerEnabled

        implicitWidth: vertical ? 36 : rowLayout.implicitWidth + 24
        implicitHeight: vertical ? columnLayout.implicitHeight + 24 : 36

        Rectangle {
            anchors.fill: parent
            color: Colors.primary
            opacity: root.popupOpen ? 0 : (root.isHovered ? 0.25 : 0)
            radius: parent.radius ?? 0

            Behavior on opacity {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                }
            }
        }

        RowLayout {
            id: rowLayout
            visible: !root.vertical
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: dayDisplay
                text: root.weatherAvailable ? WeatherService.weatherSymbol : root.currentDayAbbrev
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: root.weatherAvailable ? 16 : Config.theme.fontSize
                font.family: root.weatherAvailable ? Config.theme.font : Config.theme.font
                font.bold: !root.weatherAvailable
            }

            Separator {
                id: separator
                vert: true
            }

            Text {
                id: timeDisplay
                text: root.currentTime
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
            }
        }

        ColumnLayout {
            id: columnLayout
            visible: root.vertical
            anchors.centerIn: parent
            spacing: 4
            Layout.alignment: Qt.AlignHCenter

            Text {
                id: dayDisplayV
                text: root.weatherAvailable ? WeatherService.weatherSymbol : root.currentDayAbbrev
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: root.weatherAvailable ? 16 : Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: !root.weatherAvailable
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                Layout.alignment: Qt.AlignHCenter
            }

            Separator {
                id: separatorV
                vert: false
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: hoursDisplayV
                text: root.currentHours
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: minutesDisplayV
                text: root.currentMinutes
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                Layout.alignment: Qt.AlignHCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
            cursorShape: Qt.PointingHandCursor
            onClicked: clockPopup.toggle()
        }
    }

    // Clock & Weather popup
    BarPopup {
        id: clockPopup
        anchorItem: buttonBg
        bar: root.bar

        contentWidth: popupContent.width + popupPadding * 2
        contentHeight: popupContent.height + popupPadding * 2

        Behavior on contentHeight {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }

        onIsOpenChanged: {
            if (isOpen && !WeatherService.dataAvailable) {
                WeatherService.updateWeather();
            }
        }

        // Content container
        Column {
            id: popupContent
            spacing: 8

            // Weather widget with sun arc
            WeatherWidget {
                id: weatherWidget
                width: 300
                height: 100
                showDebugControls: true
            }

            // Debug panel (below weather widget)
            Rectangle {
                id: debugPanel
                width: weatherWidget.width
                height: WeatherService.debugMode ? debugContent.height + 16 : 0
                radius: Styling.radius(3)
                color: Colors.surface
                clip: true
                visible: height > 0

                Behavior on height {
                    enabled: Config.animDuration > 0
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Column {
                    id: debugContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 8
                    spacing: 10

                    // Time section
                    Column {
                        width: parent.width
                        spacing: 6

                        Row {
                            spacing: 4

                            Text {
                                text: "Time:"
                                color: Colors.overSurface
                                font.pixelSize: Config.theme.fontSize - 2
                                opacity: 0.7
                            }

                            Text {
                                text: {
                                    var h = Math.floor(WeatherService.debugHour);
                                    var m = Math.round((WeatherService.debugHour - h) * 60);
                                    return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                                }
                                color: Colors.overSurface
                                font.pixelSize: Config.theme.fontSize - 2
                                font.weight: Font.Bold
                            }

                            Text {
                                text: WeatherService.debugIsDay ? "☀" : "☽"
                                font.pixelSize: Config.theme.fontSize
                            }
                        }

                        // Time slider
                        Rectangle {
                            width: parent.width
                            height: 20
                            radius: 10
                            color: Colors.background

                            Rectangle {
                                x: 3
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.max(14, (parent.width - 6) * (WeatherService.debugHour / 24))
                                height: 14
                                radius: 7
                                color: Colors.primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: function (mouse) {
                                    if (pressed) {
                                        var ratio = Math.max(0, Math.min(1, mouse.x / width));
                                        WeatherService.debugHour = ratio * 24;
                                    }
                                }
                                onPressed: function (mouse) {
                                    var ratio = Math.max(0, Math.min(1, mouse.x / width));
                                    WeatherService.debugHour = ratio * 24;
                                }
                            }
                        }
                    }

                    // Weather section
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Weather"
                            color: Colors.overSurface
                            font.pixelSize: Config.theme.fontSize - 2
                            opacity: 0.7
                        }

                        Grid {
                            width: parent.width
                            columns: 6
                            spacing: 4

                            Repeater {
                                model: [
                                    {
                                        code: 0,
                                        emoji: "☀️",
                                        name: "Clear"
                                    },
                                    {
                                        code: 1,
                                        emoji: "🌤️",
                                        name: "Mainly clear"
                                    },
                                    {
                                        code: 2,
                                        emoji: "⛅",
                                        name: "Partly cloudy"
                                    },
                                    {
                                        code: 3,
                                        emoji: "☁️",
                                        name: "Overcast"
                                    },
                                    {
                                        code: 45,
                                        emoji: "🌫️",
                                        name: "Fog"
                                    },
                                    {
                                        code: 51,
                                        emoji: "🌦️",
                                        name: "Drizzle"
                                    },
                                    {
                                        code: 61,
                                        emoji: "🌧️",
                                        name: "Rain"
                                    },
                                    {
                                        code: 65,
                                        emoji: "🌧️",
                                        name: "Heavy rain"
                                    },
                                    {
                                        code: 71,
                                        emoji: "❄️",
                                        name: "Snow"
                                    },
                                    {
                                        code: 75,
                                        emoji: "❄️",
                                        name: "Heavy snow"
                                    },
                                    {
                                        code: 95,
                                        emoji: "⛈️",
                                        name: "Thunder"
                                    },
                                    {
                                        code: 96,
                                        emoji: "🌩️",
                                        name: "Hail"
                                    }
                                ]

                                Rectangle {
                                    id: weatherBtn
                                    required property var modelData
                                    required property int index

                                    width: (debugContent.width - 20) / 6
                                    height: width
                                    radius: Styling.radius(1)
                                    color: WeatherService.debugWeatherCode === modelData.code ? Colors.primary : (weatherBtnMouse.containsMouse ? Colors.background : "transparent")
                                    border.color: WeatherService.debugWeatherCode === modelData.code ? Colors.primary : Colors.outline
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: weatherBtn.modelData.emoji
                                        font.pixelSize: 16
                                    }

                                    StyledToolTip {
                                        text: weatherBtn.modelData.name
                                        visible: weatherBtnMouse.containsMouse
                                    }

                                    MouseArea {
                                        id: weatherBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: WeatherService.debugWeatherCode = weatherBtn.modelData.code
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function scheduleNextDayUpdate() {
        var now = new Date();
        var next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 1);
        var ms = next - now;
        dayUpdateTimer.interval = ms;
        dayUpdateTimer.start();
    }

    function updateDay() {
        var now = new Date();
        var day = Qt.formatDateTime(now, Qt.locale(), "ddd");
        root.currentDayAbbrev = day.slice(0, 3).charAt(0).toUpperCase() + day.slice(1, 3);
        root.currentFullDate = Qt.formatDateTime(now, Qt.locale(), "dddd, MMMM d, yyyy");
        scheduleNextDayUpdate();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            var formatted = Qt.formatDateTime(now, "hh:mm");
            var parts = formatted.split(":");
            root.currentTime = formatted;
            root.currentHours = parts[0];
            root.currentMinutes = parts[1];
        }
    }

    Timer {
        id: dayUpdateTimer
        repeat: false
        running: false
        onTriggered: updateDay()
    }

    Component.onCompleted: {
        var now = new Date();
        var formatted = Qt.formatDateTime(now, "hh:mm");
        var parts = formatted.split(":");
        root.currentTime = formatted;
        root.currentHours = parts[0];
        root.currentMinutes = parts[1];
        updateDay();
    }
}
