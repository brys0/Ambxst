pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property string defaultFont: "Roboto Condensed"

    readonly property QtObject fontSize: QtObject {
        readonly property int small: 10
        readonly property int medium: 12
        readonly property int large: 14
        readonly property int xlarge: 16
    }

    readonly property FontMetrics fontMetrics: FontMetrics {
        font.family: defaultFont
    }
}
