pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config

Item {
    id: root

    property int maxContentWidth: 480
    readonly property int contentWidth: Math.min(width, maxContentWidth)
    readonly property real sideMargin: (width - contentWidth) / 2

    // Current category being viewed
    property string currentCategory: "ambxst"

    // Edit mode state
    property bool editMode: false
    property int editingIndex: -1
    property var editingBind: null

    readonly property var categories: [
        { id: "ambxst", label: "Ambxst", icon: Icons.widgets },
        { id: "custom", label: "Custom", icon: Icons.gear }
    ]

    function formatModifiers(modifiers) {
        if (!modifiers || modifiers.length === 0) return "";
        return modifiers.join(" + ");
    }

    function formatKeybind(bind) {
        const mods = formatModifiers(bind.modifiers);
        return mods ? mods + " + " + bind.key : bind.key;
    }

    // Get ambxst binds as a flat list
    function getAmbxstBinds() {
        const adapter = Config.keybindsLoader.adapter;
        if (!adapter || !adapter.ambxst) return [];

        const binds = [];
        const ambxst = adapter.ambxst;

        // Dashboard binds
        if (ambxst.dashboard) {
            const dashboardKeys = ["widgets", "clipboard", "emoji", "tmux", "kanban", "wallpapers", "assistant", "notes"];
            for (const key of dashboardKeys) {
                if (ambxst.dashboard[key]) {
                    binds.push({
                        category: "Dashboard",
                        name: key.charAt(0).toUpperCase() + key.slice(1),
                        path: "ambxst.dashboard." + key,
                        bind: ambxst.dashboard[key]
                    });
                }
            }
        }

        // System binds
        if (ambxst.system) {
            const systemKeys = ["overview", "powermenu", "config", "lockscreen"];
            for (const key of systemKeys) {
                if (ambxst.system[key]) {
                    binds.push({
                        category: "System",
                        name: key.charAt(0).toUpperCase() + key.slice(1),
                        path: "ambxst.system." + key,
                        bind: ambxst.system[key]
                    });
                }
            }
        }

        return binds;
    }

    // Get custom binds
    function getCustomBinds() {
        const adapter = Config.keybindsLoader.adapter;
        if (!adapter || !adapter.custom) return [];
        return adapter.custom;
    }

    Flickable {
        id: mainFlickable
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: mainColumn
            width: mainFlickable.width
            spacing: 8

            // Header
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: titlebar.height

                PanelTitlebar {
                    id: titlebar
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: "Keybinds"
                    statusText: ""

                    actions: [
                        {
                            icon: Icons.sync,
                            tooltip: "Reload binds",
                            onClicked: function() {
                                Config.keybindsLoader.reload();
                            }
                        }
                    ]
                }
            }

            // Category selector
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: categoryRow.height

                Row {
                    id: categoryRow
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Repeater {
                        model: root.categories

                        delegate: StyledRect {
                            id: categoryTag
                            required property var modelData
                            required property int index

                            property bool isSelected: root.currentCategory === modelData.id
                            property bool isHovered: false

                            variant: isSelected ? "primary" : (isHovered ? "focus" : "common")
                            enableShadow: true
                            width: categoryContent.width + 32
                            height: 36
                            radius: Styling.radius(-2)

                            Row {
                                id: categoryContent
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: categoryTag.modelData.icon
                                    font.family: Icons.font
                                    font.pixelSize: 14
                                    color: categoryTag.itemColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: categoryTag.modelData.label
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    font.weight: categoryTag.isSelected ? Font.Bold : Font.Normal
                                    color: categoryTag.itemColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: categoryTag.isHovered = true
                                onExited: categoryTag.isHovered = false
                                onClicked: root.currentCategory = categoryTag.modelData.id
                            }
                        }
                    }
                }
            }

            // Content area
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: contentColumn.implicitHeight

                ColumnLayout {
                    id: contentColumn
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    // Ambxst binds view
                    Repeater {
                        id: ambxstRepeater
                        model: root.currentCategory === "ambxst" ? root.getAmbxstBinds() : []

                        delegate: BindItem {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            bindName: modelData.name
                            bindCategory: modelData.category
                            keybindText: root.formatKeybind(modelData.bind)
                            dispatcher: modelData.bind.dispatcher
                            argument: modelData.bind.argument || ""
                            isAmbxst: true

                            onEditRequested: {
                                root.editingIndex = index;
                                root.editingBind = modelData;
                                root.editMode = true;
                            }
                        }
                    }

                    // Custom binds view
                    Repeater {
                        id: customRepeater
                        model: root.currentCategory === "custom" ? root.getCustomBinds() : []

                        delegate: BindItem {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            bindName: modelData.dispatcher
                            bindCategory: modelData.flags ? "bind" + modelData.flags : "bind"
                            keybindText: root.formatKeybind(modelData)
                            dispatcher: modelData.dispatcher
                            argument: modelData.argument || ""
                            isEnabled: modelData.enabled !== false
                            isAmbxst: false

                            onToggleEnabled: {
                                const customBinds = Config.keybindsLoader.adapter.custom;
                                if (customBinds && customBinds[index]) {
                                    let newBinds = [];
                                    for (let i = 0; i < customBinds.length; i++) {
                                        if (i === index) {
                                            let updatedBind = Object.assign({}, customBinds[i]);
                                            updatedBind.enabled = !isEnabled;
                                            newBinds.push(updatedBind);
                                        } else {
                                            newBinds.push(customBinds[i]);
                                        }
                                    }
                                    Config.keybindsLoader.adapter.custom = newBinds;
                                }
                            }

                            onEditRequested: {
                                root.editingIndex = index;
                                root.editingBind = modelData;
                                root.editMode = true;
                            }
                        }
                    }

                    // Empty state
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        visible: (root.currentCategory === "ambxst" && ambxstRepeater.count === 0) ||
                                 (root.currentCategory === "custom" && customRepeater.count === 0)
                        text: root.currentCategory === "ambxst" ? "No Ambxst binds configured" : "No custom binds configured"
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(0)
                        color: Colors.overSurfaceVariant
                    }
                }
            }
        }
    }

    // Edit overlay
    Rectangle {
        id: editOverlay
        anchors.fill: parent
        color: Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.9)
        visible: root.editMode
        opacity: root.editMode ? 1 : 0

        Behavior on opacity {
            enabled: Config.animDuration > 0
            NumberAnimation { duration: Config.animDuration / 2 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.editMode = false
        }

        StyledRect {
            id: editDialog
            variant: "pane"
            width: Math.min(400, parent.width - 32)
            height: editDialogContent.implicitHeight + 32
            anchors.centerIn: parent
            radius: Styling.radius(0)
            enableShadow: true

            MouseArea {
                anchors.fill: parent
                onClicked: {} // Prevent closing when clicking dialog
            }

            ColumnLayout {
                id: editDialogContent
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Edit Keybind"
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(2)
                    font.weight: Font.Bold
                    color: Colors.overBackground
                }

                Text {
                    visible: root.editingBind !== null
                    text: root.editingBind ? (root.editingBind.name || root.editingBind.dispatcher || "") : ""
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(0)
                    color: Colors.overSurfaceVariant
                }

                // Current keybind display
                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    variant: "common"
                    radius: Styling.radius(-2)

                    Text {
                        anchors.centerIn: parent
                        text: root.editingBind ? root.formatKeybind(root.editingBind.bind || root.editingBind) : ""
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(1)
                        font.weight: Font.Medium
                        color: Colors.primary
                    }
                }

                Text {
                    text: "Editing keybinds directly is not yet supported.\nPlease edit ~/.config/Ambxst/binds.json manually."
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(-1)
                    color: Colors.overSurfaceVariant
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // Close button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Item { Layout.fillWidth: true }

                    StyledRect {
                        variant: closeButtonArea.containsMouse ? "primaryfocus" : "primary"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 36
                        radius: Styling.radius(-2)

                        Text {
                            anchors.centerIn: parent
                            text: "Close"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(0)
                            font.weight: Font.Medium
                            color: parent.itemColor
                        }

                        MouseArea {
                            id: closeButtonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.editMode = false
                        }
                    }
                }
            }
        }
    }

    // BindItem component
    component BindItem: StyledRect {
        id: bindItem

        property string bindName: ""
        property string bindCategory: ""
        property string keybindText: ""
        property string dispatcher: ""
        property string argument: ""
        property bool isEnabled: true
        property bool isAmbxst: true
        property bool isHovered: false

        signal editRequested()
        signal toggleEnabled()

        variant: isHovered ? "focus" : "common"
        height: 56
        radius: Styling.radius(-2)
        enableShadow: true
        opacity: isEnabled ? 1 : 0.5

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // Keybind display
            StyledRect {
                variant: "pane"
                Layout.preferredWidth: keybindLabel.width + 24
                Layout.preferredHeight: 32
                radius: Styling.radius(-4)

                Text {
                    id: keybindLabel
                    anchors.centerIn: parent
                    text: bindItem.keybindText
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(-1)
                    font.weight: Font.Medium
                    color: Colors.primary
                }
            }

            // Info column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: bindItem.bindName
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(0)
                    font.weight: Font.Medium
                    color: bindItem.itemColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: bindItem.argument || bindItem.dispatcher
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(-2)
                    color: Colors.overSurfaceVariant
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: text !== ""
                }
            }

            // Category badge
            Text {
                text: bindItem.bindCategory
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(-2)
                color: Colors.overSurfaceVariant
            }

            // Toggle for custom binds
            Switch {
                visible: !bindItem.isAmbxst
                checked: bindItem.isEnabled
                onCheckedChanged: {
                    if (checked !== bindItem.isEnabled) {
                        bindItem.toggleEnabled();
                    }
                }

                indicator: Rectangle {
                    implicitWidth: 36
                    implicitHeight: 18
                    radius: height / 2
                    color: parent.checked ? Colors.primary : Colors.surfaceBright
                    border.color: parent.checked ? Colors.primary : Colors.outline

                    Rectangle {
                        x: parent.parent.checked ? parent.width - width - 2 : 2
                        y: 2
                        width: parent.height - 4
                        height: width
                        radius: width / 2
                        color: parent.parent.checked ? Colors.background : Colors.overSurfaceVariant

                        Behavior on x {
                            enabled: Config.animDuration > 0
                            NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                        }
                    }
                }
                background: null
            }

            // Edit button
            Button {
                id: editButton
                flat: true
                implicitWidth: 32
                implicitHeight: 32

                background: StyledRect {
                    variant: editButton.hovered ? "primaryfocus" : "common"
                    radius: Styling.radius(-4)
                }

                contentItem: Text {
                    text: Icons.edit
                    font.family: Icons.font
                    font.pixelSize: 14
                    color: editButton.hovered ? Colors.overPrimary : Colors.overBackground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: bindItem.editRequested()

                StyledToolTip {
                    visible: editButton.hovered
                    tooltipText: "Edit keybind"
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: bindItem.isHovered = true
            onExited: bindItem.isHovered = false
        }
    }
}
