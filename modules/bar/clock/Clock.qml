pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.theme
import qs.modules.components
import qs.modules.services

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
        visualMargin: 8
        popupPadding: 0

        contentWidth: 260
        contentHeight: 140

        // Weather widget with sun arc
        Item {
            id: popupContent
            anchors.fill: parent
            anchors.margins: Config.theme.srPopup.border[1]
            visible: root.weatherAvailable

            // Weather card with gradient background
            Rectangle {
                id: weatherCard
                anchors.fill: parent
                radius: Styling.radius(4 - Config.theme.srPopup.border[1])
                clip: true

                // Color blending helper function
                function blendColors(color1, color2, color3, blend) {
                    var r = color1.r * blend.day + color2.r * blend.evening + color3.r * blend.night;
                    var g = color1.g * blend.day + color2.g * blend.evening + color3.g * blend.night;
                    var b = color1.b * blend.day + color2.b * blend.evening + color3.b * blend.night;
                    return Qt.rgba(r, g, b, 1);
                }

                // Color definitions for each time of day
                // Day colors (sky blue)
                readonly property color dayTop: "#87CEEB"
                readonly property color dayMid: "#B0E0E6"
                readonly property color dayBot: "#E0F6FF"
                
                // Evening colors (sunset)
                readonly property color eveningTop: "#1a1a2e"
                readonly property color eveningMid: "#e94560"
                readonly property color eveningBot: "#ffeaa7"
                
                // Night colors (dark blue)
                readonly property color nightTop: "#0f0f23"
                readonly property color nightMid: "#1a1a3a"
                readonly property color nightBot: "#2d2d5a"

                // Blended colors based on time
                readonly property var blend: WeatherService.effectiveTimeBlend
                readonly property color topColor: blendColors(dayTop, eveningTop, nightTop, blend)
                readonly property color midColor: blendColors(dayMid, eveningMid, nightMid, blend)
                readonly property color botColor: blendColors(dayBot, eveningBot, nightBot, blend)

                // Dynamic gradient based on time of day (smooth interpolation)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: weatherCard.topColor }
                    GradientStop { position: 0.5; color: weatherCard.midColor }
                    GradientStop { position: 1.0; color: weatherCard.botColor }
                }

                // Sun arc container
                Item {
                    id: arcContainer
                    anchors.fill: parent

                    // Arc dimensions - elliptical arc that fits within the container
                    property real arcWidth: width - 40  // Horizontal span
                    property real arcHeight: 70  // Vertical height of the arc
                    property real arcCenterX: width / 2
                    property real arcCenterY: height - 12  // Position at bottom edge

                    // The arc path (upper half of ellipse only)
                    Canvas {
                        id: arcCanvas
                        anchors.fill: parent

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = WeatherService.effectiveIsDay ? 
                                "rgba(255, 255, 255, 0.3)" : "rgba(255, 255, 255, 0.15)";
                            ctx.lineWidth = 1.5;
                            
                            var cx = arcContainer.arcCenterX;
                            var cy = arcContainer.arcCenterY;
                            var rx = arcContainer.arcWidth / 2;
                            var ry = arcContainer.arcHeight;
                            
                            // Draw only the upper half of the ellipse manually
                            ctx.beginPath();
                            ctx.moveTo(cx - rx, cy);
                            
                            // Use quadratic bezier curves to approximate upper ellipse arc
                            var steps = 50;
                            for (var i = 0; i <= steps; i++) {
                                var angle = Math.PI - (Math.PI * i / steps);  // PI to 0
                                var x = cx + rx * Math.cos(angle);
                                var y = cy - ry * Math.sin(angle);  // Subtract to go up
                                ctx.lineTo(x, y);
                            }
                            
                            ctx.stroke();
                        }

                        Component.onCompleted: requestPaint()
                        
                        Connections {
                            target: WeatherService
                            function onEffectiveIsDayChanged() { arcCanvas.requestPaint() }
                        }
                        
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }

                    // Horizon line
                    Rectangle {
                        x: arcContainer.arcCenterX - arcContainer.arcWidth / 2 - 8
                        y: arcContainer.arcCenterY
                        width: arcContainer.arcWidth + 16
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.2)
                    }

                    // Sun/Moon indicator
                    Rectangle {
                        id: celestialBody
                        width: 20
                        height: 20
                        radius: 10

                        property real progress: WeatherService.effectiveSunProgress
                        
                        // Elliptical arc position calculation
                        property real angle: Math.PI * (1 - progress)  // PI to 0
                        property real posX: arcContainer.arcCenterX + (arcContainer.arcWidth / 2) * Math.cos(angle) - width / 2
                        property real posY: arcContainer.arcCenterY - arcContainer.arcHeight * Math.sin(angle) - height / 2

                        x: posX
                        y: posY

                        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

                        gradient: Gradient {
                            GradientStop { 
                                position: 0.0
                                color: WeatherService.effectiveIsDay ? "#FFF9C4" : "#FFFFFF"
                            }
                            GradientStop { 
                                position: 0.5
                                color: WeatherService.effectiveIsDay ? "#FFE082" : "#E8E8E8"
                            }
                            GradientStop { 
                                position: 1.0
                                color: WeatherService.effectiveIsDay ? "#FFB74D" : "#C0C0C0"
                            }
                        }

                        // Outer glow
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 12
                            height: parent.height + 12
                            radius: width / 2
                            color: "transparent"
                            border.color: WeatherService.effectiveIsDay ? 
                                Qt.rgba(1, 0.95, 0.7, 0.4) : Qt.rgba(1, 1, 1, 0.2)
                            border.width: 3
                            z: -1
                        }

                        // Inner glow
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "transparent"
                            border.color: WeatherService.effectiveIsDay ? 
                                Qt.rgba(1, 0.95, 0.7, 0.6) : Qt.rgba(1, 1, 1, 0.3)
                            border.width: 2
                            z: -1
                        }
                    }
                }

                // Text colors (interpolated)
                readonly property color textPrimary: blendColors(
                    Qt.color("#1a5276"),  // Day
                    Qt.color("#FFFFFF"),  // Evening
                    Qt.color("#FFFFFF"),  // Night
                    blend
                )
                readonly property color textSecondary: blendColors(
                    Qt.color("#2980b9"),  // Day
                    Qt.rgba(1, 1, 1, 0.7),  // Evening
                    Qt.rgba(1, 1, 1, 0.7),  // Night
                    blend
                )

                // Time of day label (top left)
                Column {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 2

                    Text {
                        text: WeatherService.effectiveTimeOfDay
                        color: weatherCard.textPrimary
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        text: WeatherService.effectiveWeatherDescription
                        color: weatherCard.textSecondary
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize - 2
                    }
                }

                // Temperature (top right)
                Text {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    text: Math.round(WeatherService.currentTemp) + Config.weather.unit + "°"
                    color: weatherCard.textPrimary
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize + 6
                    font.weight: Font.Medium
                }

                // Debug controls
                Column {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 8
                    spacing: 4
                    visible: WeatherService.debugMode

                    // Hour display and indicator
                    Row {
                        spacing: 4

                        Text {
                            text: {
                                var h = Math.floor(WeatherService.debugHour);
                                var m = Math.round((WeatherService.debugHour - h) * 60);
                                return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                            }
                            color: "#fff"
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 20; height: 20
                            radius: 10
                            color: WeatherService.debugIsDay ? "#FFE082" : "#C0C0C0"
                            Text { 
                                anchors.centerIn: parent
                                text: WeatherService.debugIsDay ? "☀" : "☽"
                                font.pixelSize: 12
                            }
                        }
                    }

                    // Hour controls
                    Row {
                        spacing: 4

                        Rectangle {
                            width: 24; height: 20
                            radius: 4
                            color: "#555"
                            Text { anchors.centerIn: parent; text: "−1h"; font.pixelSize: 8; color: "#fff" }
                            MouseArea { 
                                anchors.fill: parent
                                onClicked: WeatherService.debugHour = (WeatherService.debugHour - 1 + 24) % 24
                            }
                        }
                        Rectangle {
                            width: 24; height: 20
                            radius: 4
                            color: "#555"
                            Text { anchors.centerIn: parent; text: "+1h"; font.pixelSize: 8; color: "#fff" }
                            MouseArea { 
                                anchors.fill: parent
                                onClicked: WeatherService.debugHour = (WeatherService.debugHour + 1) % 24
                            }
                        }
                    }

                    // Weather code control
                    Row {
                        spacing: 4

                        Rectangle {
                            width: 50; height: 20
                            radius: 4
                            color: "#555"
                            Text { anchors.centerIn: parent; text: WeatherService.effectiveWeatherSymbol; font.pixelSize: 12 }
                            MouseArea { 
                                anchors.fill: parent
                                onClicked: {
                                    var codes = [0, 1, 2, 3, 45, 51, 61, 71, 80, 95];
                                    var idx = codes.indexOf(WeatherService.debugWeatherCode);
                                    WeatherService.debugWeatherCode = codes[(idx + 1) % codes.length];
                                }
                            }
                        }
                    }
                }

                // Debug toggle button
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 8
                    width: 20; height: 20
                    radius: 10
                    color: WeatherService.debugMode ? Colors.primary : "#555"
                    opacity: 0.8

                    Text {
                        anchors.centerIn: parent
                        text: "D"
                        font.pixelSize: 10
                        font.bold: true
                        color: "#fff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: WeatherService.debugMode = !WeatherService.debugMode
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
