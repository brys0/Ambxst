import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.modules.theme
import qs.modules.components

BgRect {
    id: clockContainer

    property string currentTime: ""
    property string weatherText: ""
    property bool weatherVisible: false

    Layout.preferredWidth: (weatherVisible ? weatherDisplay.implicitWidth : 0) + timeDisplay.implicitWidth + (weatherVisible ? 42 : 24)
    Layout.preferredHeight: 36

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: weatherDisplay
            text: clockContainer.weatherText
            color: Colors.adapter.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            visible: clockContainer.weatherVisible
        }

        Text {
            text: "•"
            color: Colors.adapter.outline
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            visible: clockContainer.weatherVisible
        }

        Text {
            id: timeDisplay
            text: clockContainer.currentTime
            color: Colors.adapter.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }
    }

    function buildWeatherUrl() {
        var base = "wttr.in/";
        if (Config.weather.location.length > 0) {
            base += Config.weather.location;
        }
        base += "?format=%c+%t";
        if (Config.weather.unit === "C") {
            base += "&m";
        } else if (Config.weather.unit === "F") {
            base += "&u";
        }
        return base;
    }

    function updateWeather() {
        weatherProcess.command = ["curl", buildWeatherUrl()];
        weatherProcess.running = true;
    }

    Process {
        id: weatherProcess
        running: false
        command: ["curl", buildWeatherUrl()]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                clockContainer.weatherText = text.trim().replace(/ /g, '');
                clockContainer.weatherVisible = true;
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                console.log("Weather fetch failed");
                clockContainer.weatherVisible = false;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            clockContainer.currentTime = Qt.formatDateTime(now, "hh:mm:ss");
        }
    }

    Connections {
        target: Config.weather
        function onLocationChanged() {
            updateWeather();
        }
        function onUnitChanged() {
            updateWeather();
        }
    }

    Timer {
        interval: 600000 // 10 minutes
        running: true
        repeat: true
        onTriggered: {
            updateWeather();
        }
    }

    Component.onCompleted: {
        updateWeather();
    }
}
