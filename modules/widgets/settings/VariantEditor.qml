pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.config

Rectangle {
    id: root

    required property string variantId

    signal updateVariant(string property, var value)
    signal close

    color: Colors.surfaceContainerLow
    radius: Styling.radius(0)

    // Get the Config object for this variant (reads directly from Config)
    readonly property var variantConfig: {
        switch (variantId) {
        case "bg":
            return Config.theme.srBg;
        case "internalbg":
            return Config.theme.srInternalBg;
        case "pane":
            return Config.theme.srPane;
        case "common":
            return Config.theme.srCommon;
        case "focus":
            return Config.theme.srFocus;
        case "primary":
            return Config.theme.srPrimary;
        case "primaryfocus":
            return Config.theme.srPrimaryFocus;
        case "overprimary":
            return Config.theme.srOverPrimary;
        case "secondary":
            return Config.theme.srSecondary;
        case "secondaryfocus":
            return Config.theme.srSecondaryFocus;
        case "oversecondary":
            return Config.theme.srOverSecondary;
        case "tertiary":
            return Config.theme.srTertiary;
        case "tertiaryfocus":
            return Config.theme.srTertiaryFocus;
        case "overtertiary":
            return Config.theme.srOverTertiary;
        case "error":
            return Config.theme.srError;
        case "errorfocus":
            return Config.theme.srErrorFocus;
        case "overerror":
            return Config.theme.srOverError;
        default:
            return null;
        }
    }

    // List of available color names from Colors.qml
    readonly property var colorNames: ["background", "surface", "surfaceBright", "surfaceContainer", "surfaceContainerHigh", "surfaceContainerHighest", "surfaceContainerLow", "surfaceContainerLowest", "surfaceDim", "surfaceTint", "surfaceVariant", "primary", "primaryContainer", "primaryFixed", "primaryFixedDim", "secondary", "secondaryContainer", "secondaryFixed", "secondaryFixedDim", "tertiary", "tertiaryContainer", "tertiaryFixed", "tertiaryFixedDim", "error", "errorContainer", "overBackground", "overSurface", "overSurfaceVariant", "overPrimary", "overPrimaryContainer", "overPrimaryFixed", "overPrimaryFixedVariant", "overSecondary", "overSecondaryContainer", "overSecondaryFixed", "overSecondaryFixedVariant", "overTertiary", "overTertiaryContainer", "overTertiaryFixed", "overTertiaryFixedVariant", "overError", "overErrorContainer", "outline", "outlineVariant", "inversePrimary", "inverseSurface", "inverseOnSurface", "shadow", "scrim", "blue", "blueContainer", "overBlue", "overBlueContainer", "cyan", "cyanContainer", "overCyan", "overCyanContainer", "green", "greenContainer", "overGreen", "overGreenContainer", "magenta", "magentaContainer", "overMagenta", "overMagentaContainer", "red", "redContainer", "overRed", "overRedContainer", "yellow", "yellowContainer", "overYellow", "overYellowContainer", "white", "whiteContainer", "overWhite", "overWhiteContainer"]

    // Gradient type options
    readonly property var gradientTypes: ["linear", "radial", "halftone"]

    // Helper to update a property - updates Config directly
    function updateProp(prop, value) {
        if (variantConfig) {
            variantConfig[prop] = value;
            root.updateVariant(prop, value);
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 8
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 8
            enabled: root.variantConfig !== null

            // === GRADIENT TYPE SELECTOR ===
            Rectangle {
                id: typeSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: Colors.surfaceContainerHighest
                radius: Styling.radius(-1)

                readonly property int buttonCount: 3
                readonly property int spacing: 2
                readonly property int padding: 2

                readonly property int currentIndex: {
                    if (!root.variantConfig)
                        return 0;
                    const idx = root.gradientTypes.indexOf(root.variantConfig.gradientType);
                    return idx >= 0 ? idx : 0;
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: typeSelector.padding

                    // Sliding highlight
                    Rectangle {
                        id: typeHighlight
                        color: Colors.primary
                        z: 0
                        radius: Styling.radius(-2)

                        readonly property real buttonWidth: (parent.width - (typeSelector.buttonCount - 1) * typeSelector.spacing) / typeSelector.buttonCount

                        width: buttonWidth
                        height: parent.height
                        x: typeSelector.currentIndex * (buttonWidth + typeSelector.spacing)

                        Behavior on x {
                            enabled: Config.animDuration > 0
                            NumberAnimation {
                                duration: Config.animDuration / 2
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // Buttons
                    RowLayout {
                        anchors.fill: parent
                        spacing: typeSelector.spacing
                        z: 1

                        Repeater {
                            model: root.gradientTypes

                            Rectangle {
                                id: typeButton
                                required property string modelData
                                required property int index

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"

                                readonly property bool isSelected: typeSelector.currentIndex === index

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: {
                                            switch(typeButton.modelData) {
                                                case "linear": return Icons.arrowRightLine;
                                                case "radial": return Icons.sunFogFill;
                                                case "halftone": return Icons.grid;
                                                default: return "";
                                            }
                                        }
                                        font.family: Icons.font
                                        font.pixelSize: 14
                                        color: typeButton.isSelected ? Colors.overPrimary : Colors.overBackground
                                        anchors.verticalCenter: parent.verticalCenter

                                        Behavior on color {
                                            enabled: Config.animDuration > 0
                                            ColorAnimation {
                                                duration: Config.animDuration / 2
                                                easing.type: Easing.OutQuart
                                            }
                                        }
                                    }

                                    Text {
                                        text: typeButton.modelData.charAt(0).toUpperCase() + typeButton.modelData.slice(1)
                                        font.family: Styling.defaultFont
                                        font.pixelSize: Styling.fontSize(0)
                                        font.bold: true
                                        color: typeButton.isSelected ? Colors.overPrimary : Colors.overBackground
                                        anchors.verticalCenter: parent.verticalCenter

                                        Behavior on color {
                                            enabled: Config.animDuration > 0
                                            ColorAnimation {
                                                duration: Config.animDuration / 2
                                                easing.type: Easing.OutQuart
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.updateProp("gradientType", typeButton.modelData)
                                }
                            }
                        }
                    }
                }
            }

            // === MAIN PROPERTIES ROW ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Item Color
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    color: Colors.surfaceContainer
                    radius: Styling.radius(-1)
                    border.color: Colors.outlineVariant
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Color preview
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Styling.radius(-2)
                            color: Config.resolveColor(root.variantConfig ? root.variantConfig.itemColor : "surface")
                            border.color: Colors.outline
                            border.width: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Item Color"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-2)
                                font.bold: true
                                color: Colors.overBackground
                                opacity: 0.6
                            }

                            Text {
                                text: {
                                    if (!root.variantConfig) return "";
                                    const val = root.variantConfig.itemColor;
                                    return (val && val.toString().startsWith("#")) ? "Custom" : val;
                                }
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: Colors.overBackground
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: Icons.caretDown
                            font.family: Icons.font
                            font.pixelSize: 14
                            color: Colors.overBackground
                            opacity: 0.5
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: itemColorPopup.open()
                    }

                    Popup {
                        id: itemColorPopup
                        y: parent.height + 4
                        width: Math.min(parent.width, 300)
                        height: 290
                        padding: 4

                        background: Rectangle {
                            color: Colors.surfaceContainerLow
                            radius: Styling.radius(-1)
                            border.color: Colors.outlineVariant
                            border.width: 1
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 4

                            // Custom HEX input
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                Layout.margins: 2
                                color: itemColorHexInput.activeFocus ? Colors.surfaceContainerHigh : Colors.surfaceContainer
                                radius: Styling.radius(-2)
                                border.color: itemColorHexInput.activeFocus ? Colors.primary : Colors.outlineVariant
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 6

                                    Rectangle {
                                        Layout.preferredWidth: 20
                                        Layout.preferredHeight: 20
                                        radius: 4
                                        color: Config.resolveColor(root.variantConfig ? root.variantConfig.itemColor : "surface")
                                        border.color: Colors.outline
                                        border.width: 1
                                    }

                                    Text {
                                        text: "#"
                                        font.family: "monospace"
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.overBackground
                                        opacity: 0.6
                                    }

                                    TextInput {
                                        id: itemColorHexInput
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        property string currentHex: {
                                            if (!root.variantConfig) return "000000";
                                            const val = root.variantConfig.itemColor;
                                            if (val && val.toString().startsWith("#")) {
                                                return val.replace("#", "").toUpperCase();
                                            }
                                            const resolved = Config.resolveColor(val);
                                            return resolved ? resolved.toString().replace("#", "").toUpperCase().slice(0, 6) : "000000";
                                        }

                                        text: currentHex
                                        onCurrentHexChanged: text = currentHex
                                        font.family: "monospace"
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.overBackground
                                        verticalAlignment: Text.AlignVCenter
                                        selectByMouse: true
                                        maximumLength: 8

                                        validator: RegularExpressionValidator {
                                            regularExpression: /[0-9A-Fa-f]{0,8}/
                                        }

                                        onTextEdited: {
                                            // Solo aplicar cuando el usuario escribe manualmente
                                            let hex = text.trim();
                                            if (hex.length === 6 || hex.length === 8) {
                                                root.updateProp("itemColor", "#" + hex.toUpperCase());
                                            }
                                        }

                                        Keys.onReturnPressed: {
                                            let hex = text.trim();
                                            if (hex.length >= 6) {
                                                root.updateProp("itemColor", "#" + hex.toUpperCase());
                                            }
                                            focus = false;
                                        }
                                        Keys.onEnterPressed: Keys.onReturnPressed(event)
                                    }

                                        Text {
                                            text: "Custom"
                                            font.family: Styling.defaultFont
                                            font.pixelSize: Styling.fontSize(-1)
                                            color: Colors.overBackground
                                            opacity: 0.5
                                        }

                                        Button {
                                            id: dotColorPickerButton
                                            Layout.preferredWidth: 24
                                            Layout.preferredHeight: 24

                                            background: Rectangle {
                                                color: dotColorPickerButton.hovered ? Colors.surfaceContainerHigh : "transparent"
                                                radius: Styling.radius(-4)
                                            }

                                            contentItem: Text {
                                                text: Icons.picker
                                                font.family: Icons.font
                                                font.pixelSize: 14
                                                color: Colors.overBackground
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: dotColorDialog.open()

                                            ToolTip.visible: hovered
                                            ToolTip.text: "Color picker"
                                            ToolTip.delay: 500
                                        }
                                    }
                                }

                                ColorDialog {
                                    id: dotColorDialog
                                    title: "Select Dot Color"
                                    selectedColor: Config.resolveColor(root.variantConfig ? root.variantConfig.halftoneDotColor : "surface")

                                    onAccepted: {
                                        root.updateProp("halftoneDotColor", selectedColor.toString().toUpperCase());
                                    }
                                }

                            // Separator
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.leftMargin: 8
                                Layout.rightMargin: 8
                                color: Colors.outline
                                opacity: 0.2
                            }

                            // Color list
                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: root.colorNames

                                delegate: ItemDelegate {
                                    id: colorItem
                                    required property string modelData
                                    required property int index

                                    width: ListView.view.width
                                    height: 32

                                    background: Rectangle {
                                        color: colorItem.hovered ? Colors.surfaceContainerHigh : "transparent"
                                        radius: Styling.radius(-2)
                                    }

                                    contentItem: RowLayout {
                                        spacing: 8

                                        Rectangle {
                                            Layout.preferredWidth: 20
                                            Layout.preferredHeight: 20
                                            radius: 4
                                            color: Colors[colorItem.modelData] || "transparent"
                                            border.color: Colors.outline
                                            border.width: 1
                                        }

                                        Text {
                                            text: colorItem.modelData
                                            font.family: Styling.defaultFont
                                            font.pixelSize: Styling.fontSize(0)
                                            color: Colors.overBackground
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: Icons.accept
                                            font.family: Icons.font
                                            font.pixelSize: 14
                                            color: Colors.primary
                                            visible: root.variantConfig && root.variantConfig.itemColor === colorItem.modelData
                                        }
                                    }

                                    onClicked: {
                                        root.updateProp("itemColor", colorItem.modelData);
                                        itemColorPopup.close();
                                    }
                                }
                            }
                        }
                    }
                }

                // Opacity & Border
                Rectangle {
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 56
                    color: Colors.surfaceContainer
                    radius: Styling.radius(-1)
                    border.color: Colors.outlineVariant
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

                        // Opacity
                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Opacity"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-2)
                                font.bold: true
                                color: Colors.overBackground
                                opacity: 0.6
                            }

                            Text {
                                text: root.variantConfig ? (root.variantConfig.opacity * 100).toFixed(0) + "%" : "100%"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(1)
                                font.bold: true
                                color: Colors.overBackground
                            }
                        }

                        // Separator
                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            color: Colors.outline
                            opacity: 0.3
                        }

                        // Border
                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Border"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-2)
                                font.bold: true
                                color: Colors.overBackground
                                opacity: 0.6
                            }

                            Text {
                                text: root.variantConfig ? root.variantConfig.border[1] + "px" : "0px"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(1)
                                font.bold: true
                                color: Colors.overBackground
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: opacityBorderPopup.open()
                    }

                    Popup {
                        id: opacityBorderPopup
                        x: parent.width - width
                        y: parent.height + 4
                        width: 260
                        padding: 12

                        background: Rectangle {
                            color: Colors.surfaceContainerLow
                            radius: Styling.radius(-1)
                            border.color: Colors.outlineVariant
                            border.width: 1
                        }

                        ColumnLayout {
                            width: parent.width
                            spacing: 16

                            // Opacity slider
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "Opacity"
                                        font.family: Styling.defaultFont
                                        font.pixelSize: Styling.fontSize(0)
                                        font.bold: true
                                        color: Colors.overBackground
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.variantConfig ? (root.variantConfig.opacity * 100).toFixed(0) + "%" : "100%"
                                        font.family: Styling.defaultFont
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.primary
                                        font.bold: true
                                    }
                                }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24
                                    value: root.variantConfig ? root.variantConfig.opacity : 1.0
                                    vertical: false
                                    resizeParent: false
                                    scroll: false
                                    tooltip: false
                                    onValueChanged: {
                                        if (root.variantConfig && Math.abs(value - root.variantConfig.opacity) > 0.001) {
                                            root.updateProp("opacity", value);
                                        }
                                    }
                                }
                            }

                            // Border section
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "Border Width"
                                        font.family: Styling.defaultFont
                                        font.pixelSize: Styling.fontSize(0)
                                        font.bold: true
                                        color: Colors.overBackground
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.variantConfig ? root.variantConfig.border[1] + "px" : "0px"
                                        font.family: Styling.defaultFont
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.primary
                                        font.bold: true
                                    }
                                }

                                StyledSlider {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24
                                    value: root.variantConfig ? root.variantConfig.border[1] / 16 : 0
                                    resizeParent: false
                                    scroll: false
                                    tooltip: false
                                    onValueChanged: {
                                        if (root.variantConfig) {
                                            const newWidth = Math.round(value * 16);
                                            if (newWidth !== root.variantConfig.border[1]) {
                                                root.updateProp("border", [root.variantConfig.border[0], newWidth]);
                                            }
                                        }
                                    }
                                }
                            }

                            // Border color
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Border Color"
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Styling.fontSize(0)
                                    font.bold: true
                                    color: Colors.overBackground
                                }

                                ColorSelector {
                                    Layout.fillWidth: true
                                    colorNames: root.colorNames
                                    currentValue: root.variantConfig ? root.variantConfig.border[0] : ""
                                    onColorChanged: newColor => {
                                        if (!root.variantConfig)
                                            return;
                                        let border = [newColor, root.variantConfig.border[1]];
                                        root.updateProp("border", border);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // === GRADIENT STOPS (for linear/radial) ===
            GradientStopsEditor {
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                colorNames: root.colorNames
                stops: root.variantConfig ? root.variantConfig.gradient : []
                variantId: root.variantId
                visible: root.variantConfig && root.variantConfig.gradientType !== "halftone"
                onUpdateStops: newStops => root.updateProp("gradient", newStops)
            }

            // === LINEAR SETTINGS ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: Colors.surfaceContainer
                radius: Styling.radius(-1)
                border.color: Colors.outlineVariant
                border.width: 1
                visible: root.variantConfig && root.variantConfig.gradientType === "linear"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 16

                    Text {
                        text: Icons.arrowRightLine
                        font.family: Icons.font
                        font.pixelSize: 20
                        color: Colors.primary
                        rotation: root.variantConfig ? root.variantConfig.gradientAngle : 0

                        Behavior on rotation {
                            enabled: Config.animDuration > 0
                            NumberAnimation {
                                duration: Config.animDuration / 2
                                easing.type: Easing.OutQuart
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "Angle"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(-2)
                            font.bold: true
                            color: Colors.overBackground
                            opacity: 0.6
                        }

                        Text {
                            text: root.variantConfig ? root.variantConfig.gradientAngle + "°" : "0°"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(1)
                            font.bold: true
                            color: Colors.overBackground
                        }
                    }

                    StyledSlider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        value: root.variantConfig ? root.variantConfig.gradientAngle / 360 : 0
                        resizeParent: false
                        scroll: false
                        tooltip: true
                        tooltipText: Math.round(value * 360) + "°"
                        onValueChanged: {
                            if (root.variantConfig) {
                                const newAngle = Math.round(value * 360);
                                if (newAngle !== root.variantConfig.gradientAngle) {
                                    root.updateProp("gradientAngle", newAngle);
                                }
                            }
                        }
                    }
                }
            }

            // === RADIAL SETTINGS ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: Colors.surfaceContainer
                radius: Styling.radius(-1)
                border.color: Colors.outlineVariant
                border.width: 1
                visible: root.variantConfig && root.variantConfig.gradientType === "radial"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // X Position
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "X"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(0)
                            font.bold: true
                            color: Colors.primary
                            Layout.preferredWidth: 20
                        }

                        StyledSlider {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            value: root.variantConfig ? root.variantConfig.gradientCenterX : 0.5
                            resizeParent: false
                            scroll: false
                            tooltip: true
                            tooltipText: (value * 100).toFixed(0) + "%"
                            onValueChanged: {
                                if (root.variantConfig && Math.abs(value - root.variantConfig.gradientCenterX) > 0.001) {
                                    root.updateProp("gradientCenterX", value);
                                }
                            }
                        }

                        Text {
                            text: root.variantConfig ? (root.variantConfig.gradientCenterX * 100).toFixed(0) + "%" : "50%"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(0)
                            font.bold: true
                            color: Colors.overBackground
                            Layout.preferredWidth: 40
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // Y Position
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Y"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(0)
                            font.bold: true
                            color: Colors.primary
                            Layout.preferredWidth: 20
                        }

                        StyledSlider {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            value: root.variantConfig ? root.variantConfig.gradientCenterY : 0.5
                            resizeParent: false
                            scroll: false
                            tooltip: true
                            tooltipText: (value * 100).toFixed(0) + "%"
                            onValueChanged: {
                                if (root.variantConfig && Math.abs(value - root.variantConfig.gradientCenterY) > 0.001) {
                                    root.updateProp("gradientCenterY", value);
                                }
                            }
                        }

                        Text {
                            text: root.variantConfig ? (root.variantConfig.gradientCenterY * 100).toFixed(0) + "%" : "50%"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(0)
                            font.bold: true
                            color: Colors.overBackground
                            Layout.preferredWidth: 40
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            // === HALFTONE SETTINGS ===
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: root.variantConfig && root.variantConfig.gradientType === "halftone"

                // Colors row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Dot Color
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: Colors.surfaceContainer
                        radius: Styling.radius(-1)
                        border.color: Colors.outlineVariant
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 16
                                color: Config.resolveColor(root.variantConfig ? root.variantConfig.halftoneDotColor : "surface")
                                border.color: Colors.outline
                                border.width: 1
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Dot Color"
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Styling.fontSize(-2)
                                    font.bold: true
                                    color: Colors.overBackground
                                    opacity: 0.6
                                }

                                Text {
                                    text: {
                                        if (!root.variantConfig) return "";
                                        const val = root.variantConfig.halftoneDotColor;
                                        return (val && val.toString().startsWith("#")) ? "Custom" : val;
                                    }
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Styling.fontSize(0)
                                    font.bold: true
                                    color: Colors.overBackground
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: dotColorPopup.open()
                        }

                        Popup {
                            id: dotColorPopup
                            y: parent.height + 4
                            width: Math.min(parent.width, 280)
                            height: 290
                            padding: 4

                            background: Rectangle {
                                color: Colors.surfaceContainerLow
                                radius: Styling.radius(-1)
                                border.color: Colors.outlineVariant
                                border.width: 1
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 4

                                // Custom HEX input
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    Layout.margins: 2
                                    color: dotColorHexInput.activeFocus ? Colors.surfaceContainerHigh : Colors.surfaceContainer
                                    radius: Styling.radius(-2)
                                    border.color: dotColorHexInput.activeFocus ? Colors.primary : Colors.outlineVariant
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 6

                                        Rectangle {
                                            Layout.preferredWidth: 20
                                            Layout.preferredHeight: 20
                                            radius: 10
                                            color: Config.resolveColor(root.variantConfig ? root.variantConfig.halftoneDotColor : "surface")
                                            border.color: Colors.outline
                                            border.width: 1
                                        }

                                        Text {
                                            text: "#"
                                            font.family: "monospace"
                                            font.pixelSize: Styling.fontSize(0)
                                            color: Colors.overBackground
                                            opacity: 0.6
                                        }

                                        TextInput {
                                            id: dotColorHexInput
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            property string currentHex: {
                                                if (!root.variantConfig) return "000000";
                                                const val = root.variantConfig.halftoneDotColor;
                                                if (val && val.toString().startsWith("#")) {
                                                    return val.replace("#", "").toUpperCase();
                                                }
                                                const resolved = Config.resolveColor(val);
                                                return resolved ? resolved.toString().replace("#", "").toUpperCase().slice(0, 6) : "000000";
                                            }

                                            text: currentHex
                                            onCurrentHexChanged: text = currentHex
                                            font.family: "monospace"
                                            font.pixelSize: Styling.fontSize(0)
                                            color: Colors.overBackground
                                            verticalAlignment: Text.AlignVCenter
                                            selectByMouse: true
                                            maximumLength: 8

                                            validator: RegularExpressionValidator {
                                                regularExpression: /[0-9A-Fa-f]{0,8}/
                                            }

                                            onTextEdited: {
                                                let hex = text.trim();
                                                if (hex.length === 6 || hex.length === 8) {
                                                    root.updateProp("halftoneDotColor", "#" + hex.toUpperCase());
                                                }
                                            }

                                            Keys.onReturnPressed: {
                                                let hex = text.trim();
                                                if (hex.length >= 6) {
                                                    root.updateProp("halftoneDotColor", "#" + hex.toUpperCase());
                                                }
                                                focus = false;
                                            }
                                            Keys.onEnterPressed: Keys.onReturnPressed(event)
                                        }

                                        Text {
                                            text: "Custom"
                                            font.family: Styling.defaultFont
                                            font.pixelSize: Styling.fontSize(-1)
                                            color: Colors.overBackground
                                            opacity: 0.5
                                        }

                                        Button {
                                            id: halftoneDotColorPickerButton
                                            Layout.preferredWidth: 24
                                            Layout.preferredHeight: 24

                                            background: Rectangle {
                                                color: halftoneDotColorPickerButton.hovered ? Colors.surfaceContainerHigh : "transparent"
                                                radius: Styling.radius(-4)
                                            }

                                            contentItem: Text {
                                                text: Icons.picker
                                                font.family: Icons.font
                                                font.pixelSize: 14
                                                color: Colors.overBackground
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: halftoneDotColorDialog.open()

                                            ToolTip.visible: hovered
                                            ToolTip.text: "Color picker"
                                            ToolTip.delay: 500
                                        }
                                    }
                                }

                                ColorDialog {
                                    id: halftoneDotColorDialog
                                    title: "Select Dot Color"
                                    selectedColor: Config.resolveColor(root.variantConfig ? root.variantConfig.halftoneDotColor : "surface")

                                    onAccepted: {
                                        root.updateProp("halftoneDotColor", selectedColor.toString().toUpperCase());
                                    }
                                }

                                // Separator
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    Layout.leftMargin: 8
                                    Layout.rightMargin: 8
                                    color: Colors.outline
                                    opacity: 0.2
                                }

                                // Color list
                                ListView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    model: root.colorNames

                                    delegate: ItemDelegate {
                                        id: dotColorItem
                                        required property string modelData
                                        required property int index

                                        width: ListView.view.width
                                        height: 32

                                        background: Rectangle {
                                            color: dotColorItem.hovered ? Colors.surfaceContainerHigh : "transparent"
                                            radius: Styling.radius(-2)
                                        }

                                        contentItem: RowLayout {
                                            spacing: 8

                                            Rectangle {
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                radius: 10
                                                color: Colors[dotColorItem.modelData] || "transparent"
                                                border.color: Colors.outline
                                                border.width: 1
                                            }

                                            Text {
                                                text: dotColorItem.modelData
                                                font.family: Styling.defaultFont
                                                font.pixelSize: Styling.fontSize(0)
                                                color: Colors.overBackground
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: Icons.accept
                                                font.family: Icons.font
                                                font.pixelSize: 14
                                                color: Colors.primary
                                                visible: root.variantConfig && root.variantConfig.halftoneDotColor === dotColorItem.modelData
                                            }
                                        }

                                        onClicked: {
                                            root.updateProp("halftoneDotColor", dotColorItem.modelData);
                                            dotColorPopup.close();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Background Color
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: Colors.surfaceContainer
                        radius: Styling.radius(-1)
                        border.color: Colors.outlineVariant
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: Styling.radius(-2)
                                color: Config.resolveColor(root.variantConfig ? root.variantConfig.halftoneBackgroundColor : "surface")
                                border.color: Colors.outline
                                border.width: 1
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Background"
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Styling.fontSize(-2)
                                    font.bold: true
                                    color: Colors.overBackground
                                    opacity: 0.6
                                }

                                Text {
                                    text: {
                                        if (!root.variantConfig) return "";
                                        const val = root.variantConfig.halftoneBackgroundColor;
                                        return (val && val.toString().startsWith("#")) ? "Custom" : val;
                                    }
                                    font.family: Styling.defaultFont
                                    font.pixelSize: Styling.fontSize(0)
                                    font.bold: true
                                    color: Colors.overBackground
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: bgColorPopup.open()
                        }

                        Popup {
                            id: bgColorPopup
                            x: parent.width - width
                            y: parent.height + 4
                            width: Math.min(parent.width, 280)
                            height: 290
                            padding: 4

                            background: Rectangle {
                                color: Colors.surfaceContainerLow
                                radius: Styling.radius(-1)
                                border.color: Colors.outlineVariant
                                border.width: 1
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 4

                                // Custom HEX input
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    Layout.margins: 2
                                    color: bgColorHexInput.activeFocus ? Colors.surfaceContainerHigh : Colors.surfaceContainer
                                    radius: Styling.radius(-2)
                                    border.color: bgColorHexInput.activeFocus ? Colors.primary : Colors.outlineVariant
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 6

                                        Rectangle {
                                            Layout.preferredWidth: 20
                                            Layout.preferredHeight: 20
                                            radius: 4
                                            color: Config.resolveColor(root.variantConfig ? root.variantConfig.halftoneBackgroundColor : "surface")
                                            border.color: Colors.outline
                                            border.width: 1
                                        }

                                        Text {
                                            text: "#"
                                            font.family: "monospace"
                                            font.pixelSize: Styling.fontSize(0)
                                            color: Colors.overBackground
                                            opacity: 0.6
                                        }

                                        TextInput {
                                            id: bgColorHexInput
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            property string currentHex: {
                                                if (!root.variantConfig) return "000000";
                                                const val = root.variantConfig.halftoneBackgroundColor;
                                                if (val && val.toString().startsWith("#")) {
                                                    return val.replace("#", "").toUpperCase();
                                                }
                                                const resolved = Config.resolveColor(val);
                                                return resolved ? resolved.toString().replace("#", "").toUpperCase().slice(0, 6) : "000000";
                                            }

                                            text: currentHex
                                            onCurrentHexChanged: text = currentHex
                                            font.family: "monospace"
                                            font.pixelSize: Styling.fontSize(0)
                                            color: Colors.overBackground
                                            verticalAlignment: Text.AlignVCenter
                                            selectByMouse: true
                                            maximumLength: 8

                                            validator: RegularExpressionValidator {
                                                regularExpression: /[0-9A-Fa-f]{0,8}/
                                            }

                                            onTextEdited: {
                                                let hex = text.trim();
                                                if (hex.length === 6 || hex.length === 8) {
                                                    root.updateProp("halftoneBackgroundColor", "#" + hex.toUpperCase());
                                                }
                                            }

                                            Keys.onReturnPressed: {
                                                let hex = text.trim();
                                                if (hex.length >= 6) {
                                                    root.updateProp("halftoneBackgroundColor", "#" + hex.toUpperCase());
                                                }
                                                focus = false;
                                            }
                                            Keys.onEnterPressed: Keys.onReturnPressed(event)
                                        }

                                        Text {
                                            text: "Custom"
                                            font.family: Styling.defaultFont
                                            font.pixelSize: Styling.fontSize(-1)
                                            color: Colors.overBackground
                                            opacity: 0.5
                                        }

                                        Button {
                                            id: bgColorPickerButton
                                            Layout.preferredWidth: 24
                                            Layout.preferredHeight: 24

                                            background: Rectangle {
                                                color: bgColorPickerButton.hovered ? Colors.surfaceContainerHigh : "transparent"
                                                radius: Styling.radius(-4)
                                            }

                                            contentItem: Text {
                                                text: Icons.picker
                                                font.family: Icons.font
                                                font.pixelSize: 14
                                                color: Colors.overBackground
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: bgColorDialog.open()

                                            ToolTip.visible: hovered
                                            ToolTip.text: "Color picker"
                                            ToolTip.delay: 500
                                        }
                                    }
                                }

                                ColorDialog {
                                    id: bgColorDialog
                                    title: "Select Background Color"
                                    selectedColor: Config.resolveColor(root.variantConfig ? root.variantConfig.halftoneBackgroundColor : "surface")

                                    onAccepted: {
                                        root.updateProp("halftoneBackgroundColor", selectedColor.toString().toUpperCase());
                                    }
                                }

                                // Separator
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    Layout.leftMargin: 8
                                    Layout.rightMargin: 8
                                    color: Colors.outline
                                    opacity: 0.2
                                }

                                // Color list
                                ListView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    model: root.colorNames

                                    delegate: ItemDelegate {
                                        id: bgColorItem
                                        required property string modelData
                                        required property int index

                                        width: ListView.view.width
                                        height: 32

                                        background: Rectangle {
                                            color: bgColorItem.hovered ? Colors.surfaceContainerHigh : "transparent"
                                            radius: Styling.radius(-2)
                                        }

                                        contentItem: RowLayout {
                                            spacing: 8

                                            Rectangle {
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                radius: 4
                                                color: Colors[bgColorItem.modelData] || "transparent"
                                                border.color: Colors.outline
                                                border.width: 1
                                            }

                                            Text {
                                                text: bgColorItem.modelData
                                                font.family: Styling.defaultFont
                                                font.pixelSize: Styling.fontSize(0)
                                                color: Colors.overBackground
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: Icons.accept
                                                font.family: Icons.font
                                                font.pixelSize: 14
                                                color: Colors.primary
                                                visible: root.variantConfig && root.variantConfig.halftoneBackgroundColor === bgColorItem.modelData
                                            }
                                        }

                                        onClicked: {
                                            root.updateProp("halftoneBackgroundColor", bgColorItem.modelData);
                                            bgColorPopup.close();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Halftone controls
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    color: Colors.surfaceContainer
                    radius: Styling.radius(-1)
                    border.color: Colors.outlineVariant
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        // Angle
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: Icons.grid
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: Colors.primary
                                rotation: root.variantConfig ? root.variantConfig.gradientAngle : 0
                                Layout.preferredWidth: 24

                                Behavior on rotation {
                                    enabled: Config.animDuration > 0
                                    NumberAnimation {
                                        duration: Config.animDuration / 2
                                        easing.type: Easing.OutQuart
                                    }
                                }
                            }

                            Text {
                                text: "Angle"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: Colors.overBackground
                                Layout.preferredWidth: 60
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                value: root.variantConfig ? root.variantConfig.gradientAngle / 360 : 0
                                resizeParent: false
                                scroll: false
                                tooltip: false
                                onValueChanged: {
                                    if (root.variantConfig) {
                                        const newAngle = Math.round(value * 360);
                                        if (newAngle !== root.variantConfig.gradientAngle) {
                                            root.updateProp("gradientAngle", newAngle);
                                        }
                                    }
                                }
                            }

                            Text {
                                text: root.variantConfig ? root.variantConfig.gradientAngle + "°" : "0°"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: Colors.primary
                                Layout.preferredWidth: 40
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // Dot Size Range
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: Icons.circle
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: Colors.primary
                                Layout.preferredWidth: 24
                            }

                            Text {
                                text: "Size"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: Colors.overBackground
                                Layout.preferredWidth: 60
                            }

                            Text {
                                text: root.variantConfig ? root.variantConfig.halftoneDotMin.toFixed(1) : "2.0"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-1)
                                color: Colors.overBackground
                                opacity: 0.7
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                value: root.variantConfig ? root.variantConfig.halftoneDotMin / 20 : 0.1
                                resizeParent: false
                                scroll: false
                                tooltip: false
                                onValueChanged: {
                                    if (root.variantConfig) {
                                        const newVal = value * 20;
                                        if (Math.abs(newVal - root.variantConfig.halftoneDotMin) > 0.01) {
                                            root.updateProp("halftoneDotMin", newVal);
                                        }
                                    }
                                }
                            }

                            Text {
                                text: "-"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                opacity: 0.5
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                value: root.variantConfig ? root.variantConfig.halftoneDotMax / 20 : 0.4
                                resizeParent: false
                                scroll: false
                                tooltip: false
                                onValueChanged: {
                                    if (root.variantConfig) {
                                        const newVal = value * 20;
                                        if (Math.abs(newVal - root.variantConfig.halftoneDotMax) > 0.01) {
                                            root.updateProp("halftoneDotMax", newVal);
                                        }
                                    }
                                }
                            }

                            Text {
                                text: root.variantConfig ? root.variantConfig.halftoneDotMax.toFixed(1) : "8.0"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-1)
                                color: Colors.overBackground
                                opacity: 0.7
                            }
                        }

                        // Gradient Range
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: Icons.gradientVertical
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: Colors.primary
                                Layout.preferredWidth: 24
                            }

                            Text {
                                text: "Range"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: Colors.overBackground
                                Layout.preferredWidth: 60
                            }

                            Text {
                                text: root.variantConfig ? (root.variantConfig.halftoneStart * 100).toFixed(0) + "%" : "0%"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-1)
                                color: Colors.overBackground
                                opacity: 0.7
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                value: root.variantConfig ? root.variantConfig.halftoneStart : 0
                                resizeParent: false
                                scroll: false
                                tooltip: false
                                onValueChanged: {
                                    if (root.variantConfig && Math.abs(value - root.variantConfig.halftoneStart) > 0.001) {
                                        root.updateProp("halftoneStart", value);
                                    }
                                }
                            }

                            Text {
                                text: "-"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                opacity: 0.5
                            }

                            StyledSlider {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                value: root.variantConfig ? root.variantConfig.halftoneEnd : 1
                                resizeParent: false
                                scroll: false
                                tooltip: false
                                onValueChanged: {
                                    if (root.variantConfig && Math.abs(value - root.variantConfig.halftoneEnd) > 0.001) {
                                        root.updateProp("halftoneEnd", value);
                                    }
                                }
                            }

                            Text {
                                text: root.variantConfig ? (root.variantConfig.halftoneEnd * 100).toFixed(0) + "%" : "100%"
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-1)
                                color: Colors.overBackground
                                opacity: 0.7
                            }
                        }
                    }
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
                Layout.preferredHeight: 8
            }
        }
    }
}
