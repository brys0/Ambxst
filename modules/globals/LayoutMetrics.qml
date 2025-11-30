pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    readonly property int gridRows: 3
    readonly property int gridColumns: 5
    readonly property int separatorWidth: 2
    readonly property int spacing: 8
    readonly property int adjustmentPadding: 8
    readonly property int wallpaperMargin: 4

    function calculateLeftPanelWidth(containerWidth, containerHeight, containerSpacing) {
        return 300;
    }

    function calculateRightPanelWidth(containerWidth) {
        return containerWidth - 300 - 2 * spacing - separatorWidth;
    }
}
