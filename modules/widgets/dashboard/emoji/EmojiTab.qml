import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.config

Rectangle {
    id: root
    focus: true

    // Prefix support
    property string prefixIcon: ""
    signal backspaceOnEmpty

    property int leftPanelWidth: 0

    property string searchText: ""
    property bool showResults: searchText.length > 0
    property int selectedIndex: -1
    property int selectedRecentIndex: -1
    property int lastSelectedRecentIndex: -1
    property bool isRecentFocused: false
    property bool hasNavigatedFromSearch: false
    property bool clearButtonFocused: false
    property bool clearButtonConfirmState: false
    property var emojiData: []
    property var recentEmojis: []
    property var filteredEmojis: []
    
    ListModel {
        id: emojisModel
    }
    
    ListModel {
        id: recentModel
    }

    onSelectedIndexChanged: {
        if (selectedIndex === -1 && emojiList.count > 0) {
            emojiList.positionViewAtIndex(0, ListView.Beginning);
        }
    }

    onSearchTextChanged: {
        performSearch();
    }

    function clearSearch() {
        searchText = "";
        selectedIndex = -1;
        selectedRecentIndex = -1;
        lastSelectedRecentIndex = -1;
        isRecentFocused = false;
        hasNavigatedFromSearch = false;
        clearButtonFocused = false;
        clearButtonConfirmState = false;
        searchInput.focusInput();
        
        loadInitialEmojis();
        emojiList.enableScrollAnimation = false;
        emojiList.contentY = 0;
        Qt.callLater(() => { emojiList.enableScrollAnimation = true; });
    }

    function resetClearButton() {
        clearButtonConfirmState = false;
    }

    function clearRecentEmojis() {
        recentEmojis = [];
        saveRecentEmojis();
        updateRecentModel();
        clearButtonConfirmState = false;
        clearButtonFocused = false;
        searchInput.focusInput();
    }

    function focusSearchInput() {
        searchInput.focusInput();
    }

    function performSearch() {
        if (searchText.length === 0) {
            loadInitialEmojis();
            selectedIndex = -1;
            selectedRecentIndex = -1;
            emojiList.contentY = 0;
            return;
        }
        
        updateFilteredEmojis();
    }

    function updateFilteredEmojis() {
        var filtered = [];
        var searchLower = searchText.toLowerCase();

        if (searchText.length > 0) {
            for (var i = 0; i < emojiData.length; i++) {
                var emoji = emojiData[i];
                var emojiText = emoji.emoji;
                var searchTerms = emoji.search;

                if (emojiText.includes(searchText) || searchTerms.toLowerCase().includes(searchLower)) {
                    filtered.push(emoji);
                }
            }
        }

        filteredEmojis = filtered;
        emojiList.enableScrollAnimation = false;
        emojiList.contentY = 0;

        emojisModel.clear();
        for (var i = 0; i < filtered.length; i++) {
            emojisModel.append({
                emojiId: filtered[i].search,
                emojiData: filtered[i]
            });
        }
        
        Qt.callLater(() => { emojiList.enableScrollAnimation = true; });

        if (searchText.length > 0 && filteredEmojis.length > 0 && !isRecentFocused) {
            selectedIndex = 0;
            emojiList.currentIndex = 0;
        } else if (searchText.length === 0 && !hasNavigatedFromSearch) {
            selectedIndex = -1;
            selectedRecentIndex = -1;
        }
    }

    function updateRecentModel() {
        recentModel.clear();
        for (var i = 0; i < recentEmojis.length; i++) {
            recentModel.append({
                emojiId: recentEmojis[i].search,
                emojiData: recentEmojis[i]
            });
        }
    }

    function loadEmojiData() {
        emojiProcess.command = ["bash", "-c", "sed '1,/^### DATA ###$/d' /home/adriano/Repos/Axenide/Ambxst/scripts/fuzzel-emoji.sh"];
        emojiProcess.running = true;
    }
    
    function loadInitialEmojis() {
        var initial = [];
        for (var i = 0; i < Math.min(50, emojiData.length); i++) {
            initial.push(emojiData[i]);
        }
        
        emojisModel.clear();
        for (var i = 0; i < initial.length; i++) {
            emojisModel.append({
                emojiId: initial[i].search,
                emojiData: initial[i]
            });
        }
        
        filteredEmojis = initial;
    }

    function loadRecentEmojis() {
        recentProcess.command = ["bash", "-c", "cat " + Quickshell.dataDir + "/emojis.json 2>/dev/null || echo '[]'"];
        recentProcess.running = true;
    }

    function saveRecentEmojis() {
        var jsonData = JSON.stringify(recentEmojis, null, 2);
        saveProcess.command = ["bash", "-c", "echo '" + jsonData.replace(/'/g, "'\\''") + "' > " + Quickshell.dataDir + "/emojis.json"];
        saveProcess.running = true;
    }

    function addToRecent(emoji) {
        recentEmojis = recentEmojis.filter(function (item) {
            return item.emoji !== emoji.emoji;
        });

        emoji.usage = (emoji.usage || 0) + 1;
        emoji.lastUsed = Date.now();
        recentEmojis.unshift(emoji);

        if (recentEmojis.length > 50) {
            recentEmojis = recentEmojis.slice(0, 50);
        }

        recentEmojis.sort(function (a, b) {
            if (a.usage !== b.usage) {
                return b.usage - a.usage;
            }
            return b.lastUsed - a.lastUsed;
        });

        updateRecentModel();
        saveRecentEmojis();
    }

    function copyEmoji(emoji) {
        root.addToRecent(emoji);
        Visibilities.setActiveModule("");
        ClipboardService.copyAndTypeEmoji(emoji.emoji);
    }

    function onDownPressed() {
        if (!hasNavigatedFromSearch) {
            hasNavigatedFromSearch = true;
            if (filteredEmojis.length > 0) {
                isRecentFocused = false;
                selectedRecentIndex = -1;
                recentList.currentIndex = -1;
            }
        }

        if (!isRecentFocused && emojiList.count > 0) {
            if (selectedIndex === -1) {
                selectedIndex = 0;
                emojiList.currentIndex = 0;
            } else if (selectedIndex < emojiList.count - 1) {
                selectedIndex++;
                emojiList.currentIndex = selectedIndex;
            }
        } else if (isRecentFocused && recentEmojis.length > 0) {
            if (selectedRecentIndex < recentEmojis.length - 1) {
                selectedRecentIndex++;
                recentList.currentIndex = selectedRecentIndex;
                lastSelectedRecentIndex = selectedRecentIndex;
            }
        }
    }

    function onUpPressed() {
        if (isRecentFocused) {
            if (selectedRecentIndex > 0) {
                selectedRecentIndex--;
                recentList.currentIndex = selectedRecentIndex;
                lastSelectedRecentIndex = selectedRecentIndex;
            } else if (selectedRecentIndex === 0) {
                isRecentFocused = false;
                selectedRecentIndex = -1;
                recentList.currentIndex = -1;
                hasNavigatedFromSearch = false;
            }
        } else if (selectedIndex > 0) {
            selectedIndex--;
            emojiList.currentIndex = selectedIndex;
        } else if (selectedIndex === 0) {
            selectedIndex = -1;
            emojiList.currentIndex = -1;
            hasNavigatedFromSearch = false;
        }
    }

    function onLeftPressed() {
        if (isRecentFocused && recentEmojis.length > 0) {
            isRecentFocused = false;
            selectedRecentIndex = -1;
            recentList.currentIndex = -1;
            if (filteredEmojis.length > 0) {
                if (selectedIndex === -1) {
                    selectedIndex = 0;
                }
                emojiList.currentIndex = selectedIndex;
            }
        }
    }

    function onRightPressed() {
        if (!isRecentFocused && recentEmojis.length > 0 && searchText.length === 0) {
            isRecentFocused = true;
            selectedIndex = -1;
            emojiList.currentIndex = -1;
            if (lastSelectedRecentIndex >= 0 && lastSelectedRecentIndex < recentEmojis.length) {
                selectedRecentIndex = lastSelectedRecentIndex;
            } else {
                selectedRecentIndex = 0;
                lastSelectedRecentIndex = selectedRecentIndex;
            }
            recentList.currentIndex = selectedRecentIndex;
        }
    }

    implicitWidth: 400
    implicitHeight: mainLayout.implicitHeight
    color: "transparent"

    Behavior on height {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutQuart
        }
    }

    Process {
        id: emojiProcess
        running: false

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: {
                var lines = text.trim().split('\n');
                var data = [];
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.length > 0) {
                        var parts = line.split(' ');
                        if (parts.length >= 2) {
                            var emoji = parts[0];
                            var search = parts.slice(1).join(' ');
                            data.push({
                                emoji: emoji,
                                search: search
                            });
                        }
                    }
                }
                emojiData = data;
                loadInitialEmojis();
            }
        }
    }

    Process {
        id: recentProcess
        running: false

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: {
                try {
                    recentEmojis = JSON.parse(text.trim());
                    updateRecentModel();
                } catch (e) {
                    recentEmojis = [];
                    updateRecentModel();
                }
            }
        }
    }

    Process {
        id: saveProcess
        running: false
    }

    Item {
        id: mainLayout
        anchors.fill: parent
        
        RowLayout {
            anchors.fill: parent
            spacing: 8

            Item {
                Layout.preferredWidth: root.leftPanelWidth
                Layout.fillHeight: true

                Row {
                    id: searchRow
                    width: parent.width
                    height: 48
                    anchors.top: parent.top
                    spacing: 8

                    SearchInput {
                        id: searchInput
                        width: parent.width - clearButton.width - parent.spacing
                        height: parent.height
                        text: root.searchText
                        placeholderText: "Search emojis..."
                        prefixIcon: root.prefixIcon

                        onSearchTextChanged: text => {
                            root.searchText = text;
                        }

                        onBackspaceOnEmpty: {
                            root.backspaceOnEmpty();
                        }

                        onAccepted: {
                            if (isRecentFocused && selectedRecentIndex >= 0 && selectedRecentIndex < recentEmojis.length) {
                                var selectedEmoji = recentEmojis[selectedRecentIndex];
                                if (selectedEmoji) {
                                    root.copyEmoji(selectedEmoji);
                                }
                            } else if (!isRecentFocused && selectedIndex >= 0 && selectedIndex < filteredEmojis.length) {
                                var selectedEmoji = filteredEmojis[selectedIndex];
                                if (selectedEmoji) {
                                    root.copyEmoji(selectedEmoji);
                                }
                            }
                        }

                        onEscapePressed: {
                            if (root.searchText.length === 0) {
                                Visibilities.setActiveModule("");
                            } else {
                                root.clearSearch();
                            }
                        }

                        onDownPressed: {
                            root.onDownPressed();
                        }

                        onUpPressed: {
                            root.onUpPressed();
                        }

                        onLeftPressed: {
                            root.onLeftPressed();
                        }

                        onRightPressed: {
                            root.onRightPressed();
                        }
                    }

                    StyledRect {
                        id: clearButton
                        width: root.clearButtonConfirmState ? 140 : 48
                        height: 48
                        radius: searchInput.radius
                        variant: {
                            if (root.clearButtonConfirmState) {
                                return "error";
                            } else if (root.clearButtonFocused || clearButtonMouseArea.containsMouse) {
                                return "focus";
                            } else {
                                return "pane";
                            }
                        }
                        focus: root.clearButtonFocused
                        activeFocusOnTab: true

                        Behavior on width {
                            enabled: Config.animDuration > 0
                            NumberAnimation {
                                duration: Config.animDuration
                                easing.type: Easing.OutQuart
                            }
                        }

                        onActiveFocusChanged: {
                            if (activeFocus) {
                                root.clearButtonFocused = true;
                            } else {
                                root.clearButtonFocused = false;
                                root.resetClearButton();
                            }
                        }

                        MouseArea {
                            id: clearButtonMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                if (root.clearButtonConfirmState) {
                                    root.clearRecentEmojis();
                                } else {
                                    root.clearButtonConfirmState = true;
                                }
                            }
                        }

                        Row {
                            id: clearButtonContent
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Text {
                                width: 32
                                height: parent.height
                                text: root.clearButtonConfirmState ? Icons.xeyes : Icons.broom
                                font.family: Icons.font
                                font.pixelSize: 20
                                color: root.clearButtonConfirmState ? clearButton.itemColor : Config.resolveColor(Config.theme.srOverPrimary.itemColor)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                textFormat: Text.RichText
                            }

                            Text {
                                width: parent.width - 32 - parent.spacing
                                height: parent.height
                                text: "Clear recent?"
                                font.family: Config.theme.font
                                font.weight: Font.Bold
                                font.pixelSize: Config.theme.fontSize
                                color: clearButton.itemColor
                                opacity: root.clearButtonConfirmState ? 1.0 : 0.0
                                visible: opacity > 0
                                verticalAlignment: Text.AlignVCenter

                                Behavior on opacity {
                                    enabled: Config.animDuration > 0
                                    NumberAnimation {
                                        duration: Config.animDuration / 2
                                        easing.type: Easing.OutQuart
                                    }
                                }
                            }
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.clearButtonConfirmState) {
                                    root.clearRecentEmojis();
                                } else {
                                    root.clearButtonConfirmState = true;
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                root.resetClearButton();
                                root.clearButtonFocused = false;
                                searchInput.focusInput();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier)) {
                                root.resetClearButton();
                                root.clearButtonFocused = false;
                                searchInput.focusInput();
                                event.accepted = true;
                            }
                        }
                    }
                }

                ListView {
                    id: emojiList
                    width: parent.width
                    anchors.top: searchRow.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 8
                    anchors.bottomMargin: 0
                    clip: true

                    cacheBuffer: 96
                    reuseItems: false

                    model: emojisModel
                    currentIndex: root.selectedIndex
                    
                    property bool enableScrollAnimation: true
                    
                    Behavior on contentY {
                        enabled: Config.animDuration > 0 && emojiList.enableScrollAnimation && !emojiList.moving
                        NumberAnimation {
                            duration: Config.animDuration / 2
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    onCurrentIndexChanged: {
                        if (currentIndex !== root.selectedIndex && !root.isRecentFocused) {
                            root.selectedIndex = currentIndex;
                        }
                        
                        if (currentIndex >= 0 && !root.isRecentFocused) {
                            var itemY = currentIndex * 48;
                            var viewportTop = emojiList.contentY;
                            var viewportBottom = viewportTop + emojiList.height;
                            
                            if (itemY < viewportTop) {
                                emojiList.contentY = itemY;
                            } else if (itemY + 48 > viewportBottom) {
                                emojiList.contentY = itemY + 48 - emojiList.height;
                            }
                        }
                    }

                    delegate: Rectangle {
                        required property string emojiId
                        required property var emojiData
                        required property int index

                        property var modelData: emojiData

                        width: emojiList.width
                        height: 48
                        color: "transparent"
                        radius: 16
                        
                        property color textColor: {
                            if (root.selectedIndex === index && !root.isRecentFocused) {
                                return Config.resolveColor(Config.theme.srPrimary.itemColor);
                            } else {
                                return Colors.overSurface;
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            preventStealing: false
                            propagateComposedEvents: true

                            onEntered: {
                                if (root.isRecentFocused) {
                                    root.isRecentFocused = false;
                                    root.selectedRecentIndex = -1;
                                    recentList.currentIndex = -1;
                                }
                                root.selectedIndex = index;
                                emojiList.currentIndex = index;
                            }

                            onClicked: {
                                root.copyEmoji(modelData);
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            StyledRect {
                                id: emojiIconBackground
                                width: emojiIcon.implicitWidth + 6
                                height: 32
                                radius: Config.roundness > 0 ? Math.max(Config.roundness - 4, 0) : 0
                                variant: root.selectedIndex === index && !root.isRecentFocused ? "overprimary" : "common"

                                Text {
                                    id: emojiIcon
                                    anchors.centerIn: parent
                                    color: emojiIconBackground.itemColor
                                    text: modelData.emoji
                                    font.pixelSize: 24
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Text {
                                width: parent.width - emojiIcon.implicitWidth - 6 - parent.spacing - 16
                                height: parent.height
                                text: modelData.search
                                color: textColor
                                font.family: Config.theme.font
                                font.weight: Font.Bold
                                font.pixelSize: Config.theme.fontSize
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    highlight: Item {
                        width: emojiList.width
                        height: 48
                        
                        // Calculate Y position based on index, not item position
                        y: emojiList.currentIndex * 48
                        
                        Behavior on y {
                            enabled: Config.animDuration > 0
                            NumberAnimation {
                                duration: Config.animDuration / 2
                                easing.type: Easing.OutCubic
                            }
                        }
                        
                        StyledRect {
                            anchors.fill: parent
                            variant: "primary"
                            radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                            visible: root.selectedIndex >= 0 && !root.isRecentFocused
                        }
                    }

                    highlightFollowsCurrentItem: false
                }
            }

            Rectangle {
                Layout.preferredWidth: 2
                Layout.fillHeight: true
                radius: Config.roundness
                color: Colors.surface
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Item {
                    anchors.fill: parent
                    visible: recentEmojis.length > 0 && searchText.length === 0

                    ListView {
                        id: recentList
                        anchors.fill: parent
                        orientation: ListView.Vertical
                        spacing: 0
                        clip: true
                        cacheBuffer: 96
                        reuseItems: false

                        model: recentModel
                        currentIndex: root.selectedRecentIndex
                        
                        property bool enableScrollAnimation: true
                        
                        Behavior on contentY {
                            enabled: Config.animDuration > 0 && recentList.enableScrollAnimation && !recentList.moving
                            NumberAnimation {
                                duration: Config.animDuration / 2
                                easing.type: Easing.OutCubic
                            }
                        }

                        onCurrentIndexChanged: {
                            if (currentIndex !== root.selectedRecentIndex && root.isRecentFocused) {
                                root.selectedRecentIndex = currentIndex;
                                root.lastSelectedRecentIndex = currentIndex;
                            }
                            
                            if (currentIndex >= 0 && root.isRecentFocused) {
                                var itemY = currentIndex * 48;
                                var viewportTop = recentList.contentY;
                                var viewportBottom = viewportTop + recentList.height;
                                
                                if (itemY < viewportTop) {
                                    recentList.contentY = itemY;
                                } else if (itemY + 48 > viewportBottom) {
                                    recentList.contentY = itemY + 48 - recentList.height;
                                }
                            }
                        }

                        delegate: Rectangle {
                            required property string emojiId
                            required property var emojiData
                            required property int index

                            property var modelData: emojiData

                            width: recentList.width
                            height: 48
                            color: "transparent"
                            radius: Config.roundness > 0 ? Math.max(Config.roundness - 4, 0) : 0
                            
                            property color textColor: {
                                if (root.selectedRecentIndex === index && root.isRecentFocused) {
                                    return Config.resolveColor(Config.theme.srPrimary.itemColor);
                                } else {
                                    return Colors.overSurface;
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                preventStealing: false
                                propagateComposedEvents: true

                                onEntered: {
                                    if (!root.isRecentFocused) {
                                        root.isRecentFocused = true;
                                        root.selectedIndex = -1;
                                        emojiList.currentIndex = -1;
                                    }
                                    root.selectedRecentIndex = index;
                                    root.lastSelectedRecentIndex = index;
                                    recentList.currentIndex = index;
                                }

                                onClicked: {
                                    root.copyEmoji(modelData);
                                }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8

                                StyledRect {
                                    id: recentEmojiIconBackground
                                    width: recentEmojiIcon.implicitWidth + 6
                                    height: 32
                                    radius: Config.roundness > 0 ? Math.max(Config.roundness - 4, 0) : 0
                                    variant: root.selectedRecentIndex === index && root.isRecentFocused ? "overprimary" : "common"

                                    Text {
                                        id: recentEmojiIcon
                                        anchors.centerIn: parent
                                        color: recentEmojiIconBackground.itemColor
                                        text: modelData.emoji
                                        font.pixelSize: 24
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Text {
                                    width: parent.width - recentEmojiIcon.implicitWidth - 6 - parent.spacing - 16
                                    height: parent.height
                                    text: modelData.search
                                    color: textColor
                                    font.family: Config.theme.font
                                    font.weight: Font.Bold
                                    font.pixelSize: Config.theme.fontSize
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        highlight: Item {
                            width: recentList.width
                            height: 48
                            
                            // Calculate Y position based on index, not item position
                            y: recentList.currentIndex * 48
                            
                            Behavior on y {
                                enabled: Config.animDuration > 0
                                NumberAnimation {
                                    duration: Config.animDuration / 2
                                    easing.type: Easing.OutCubic
                                }
                            }
                            
                            StyledRect {
                                anchors.fill: parent
                                variant: "primary"
                                radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                                visible: root.isRecentFocused
                            }
                        }

                        highlightFollowsCurrentItem: false
                    }
                }

                Item {
                    anchors.fill: parent
                    visible: recentEmojis.length === 0 && searchText.length === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: Icons.countdown
                            font.family: Icons.font
                            font.pixelSize: 48
                            color: Colors.surfaceBright
                            anchors.horizontalCenter: parent.horizontalCenter
                            textFormat: Text.RichText
                        }

                        Text {
                            text: "No recent emojis"
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            font.weight: Font.Bold
                            color: Colors.outline
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            Visibilities.setActiveModule("");
            event.accepted = true;
        }
    }

    Component.onCompleted: {
        loadEmojiData();
        loadRecentEmojis();
        Qt.callLater(() => {
            focusSearchInput();
        });
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            focusSearchInput();
        }
    }
}
