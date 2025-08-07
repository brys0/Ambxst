import QtQuick

Item {
    property alias sourceComponent: loader.sourceComponent
    property alias item: loader.item

    Loader {
        id: loader
        anchors.fill: parent
        active: true
    }
}
