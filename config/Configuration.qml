pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    FileView {
        id: loader
        path: Qt.resolvedUrl("./config.json")
        preload: true
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            property JsonObject theme: JsonObject {
                property bool oledMode: false
                property int roundness: 16
            }
            
            property JsonObject bar: JsonObject {
                property bool bottom: false
                property bool borderless: false
                property string topLeftIcon: "spark"
                property bool showBackground: true
                property bool verbose: true
                property list<string> screenList: []
            }
            
            property JsonObject workspaces: JsonObject {
                property int shown: 10
                property bool showAppIcons: true
                property bool alwaysShowNumbers: false
                property int showNumberDelay: 300
                property bool showNumbers: false
            }
        }
    }

    // Theme configuration
    property bool oledMode: loader.adapter.theme.oledMode
    property int roundness: loader.adapter.theme.roundness

    // Bar configuration
    property QtObject bar: loader.adapter.bar

    // Workspace configuration
    property QtObject workspaces: loader.adapter.workspaces
}