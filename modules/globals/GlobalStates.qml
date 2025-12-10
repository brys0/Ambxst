pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.modules.services
import qs.config

Singleton {
    id: root

    property var wallpaperManager: null

    // Ensure LockscreenService singleton is loaded
    Component.onCompleted: {
        // Reference the singleton to ensure it loads
        LockscreenService.toString();
    }

    // Persistent launcher state across monitors
    property string launcherSearchText: ""
    property int launcherSelectedIndex: -1
    property int launcherCurrentTab: 0

    function clearLauncherState() {
        launcherSearchText = "";
        launcherSelectedIndex = -1;
    }

    // Persistent dashboard state across monitors  
    property int dashboardCurrentTab: 0
    
    // Widgets tab internal state (for prefix-based tabs)
    // 0=launcher, 1=clipboard, 2=emoji, 3=tmux, 4=wallpapers
    property int widgetsTabCurrentIndex: 0

    // Persistent wallpaper navigation state
    property int wallpaperSelectedIndex: -1

    function clearWallpaperState() {
        wallpaperSelectedIndex = -1;
    }

    function getNotchOpen(screenName) {
        let visibilities = Visibilities.getForScreen(screenName);
        return visibilities.launcher || visibilities.dashboard || visibilities.overview;
    }

    function getActiveLauncher() {
        let active = Visibilities.getForActive();
        return active ? active.launcher : false;
    }

    function getActiveDashboard() {
        let active = Visibilities.getForActive();
        return active ? active.dashboard : false;
    }

    function getActiveOverview() {
        let active = Visibilities.getForActive();
        return active ? active.overview : false;
    }

    function getActiveNotchOpen() {
        let active = Visibilities.getForActive();
        return active ? (active.launcher || active.dashboard || active.overview) : false;
    }

    // Legacy properties for backward compatibility - use active screen
    readonly property bool notchOpen: getActiveNotchOpen()
    readonly property bool overviewOpen: getActiveOverview()
    readonly property bool launcherOpen: getActiveLauncher()
    readonly property bool dashboardOpen: getActiveDashboard()

    // Lockscreen state
    property bool lockscreenVisible: false

    // Ambxst Settings state
    property bool settingsVisible: false

    // Theme editor state - persists across tab switches
    property bool themeHasChanges: false
    property var themeSnapshot: null

    function openSettings() {
        settingsVisible = false;
        settingsVisible = true;
    }

    // Create a deep copy of the current theme config
    function createThemeSnapshot() {
        var snapshot = {};
        var theme = Config.theme;
        
        // Copy simple properties
        snapshot.roundness = theme.roundness;
        snapshot.oledMode = theme.oledMode;
        snapshot.lightMode = theme.lightMode;
        snapshot.font = theme.font;
        snapshot.fontSize = theme.fontSize;
        snapshot.tintIcons = theme.tintIcons;
        snapshot.enableCorners = theme.enableCorners;
        snapshot.animDuration = theme.animDuration;
        snapshot.shadowOpacity = theme.shadowOpacity;
        snapshot.shadowColor = theme.shadowColor;
        snapshot.shadowXOffset = theme.shadowXOffset;
        snapshot.shadowYOffset = theme.shadowYOffset;
        snapshot.shadowBlur = theme.shadowBlur;
        
        // Copy SR variants
        var variants = ["srBg", "srInternalBg", "srBarBg", "srPane", "srCommon", "srFocus",
                       "srPrimary", "srPrimaryFocus", "srOverPrimary",
                       "srSecondary", "srSecondaryFocus", "srOverSecondary",
                       "srTertiary", "srTertiaryFocus", "srOverTertiary",
                       "srError", "srErrorFocus", "srOverError"];
        
        for (var i = 0; i < variants.length; i++) {
            var name = variants[i];
            var src = theme[name];
            snapshot[name] = {
                gradient: JSON.parse(JSON.stringify(src.gradient)),
                gradientType: src.gradientType,
                gradientAngle: src.gradientAngle,
                gradientCenterX: src.gradientCenterX,
                gradientCenterY: src.gradientCenterY,
                halftoneDotMin: src.halftoneDotMin,
                halftoneDotMax: src.halftoneDotMax,
                halftoneStart: src.halftoneStart,
                halftoneEnd: src.halftoneEnd,
                halftoneDotColor: src.halftoneDotColor,
                halftoneBackgroundColor: src.halftoneBackgroundColor,
                border: JSON.parse(JSON.stringify(src.border)),
                itemColor: src.itemColor,
                opacity: src.opacity
            };
        }
        
        return snapshot;
    }

    // Restore theme from snapshot
    function restoreThemeSnapshot(snapshot) {
        if (!snapshot) return;
        
        var theme = Config.theme;
        
        // Restore simple properties
        theme.roundness = snapshot.roundness;
        theme.oledMode = snapshot.oledMode;
        theme.lightMode = snapshot.lightMode;
        theme.font = snapshot.font;
        theme.fontSize = snapshot.fontSize;
        theme.tintIcons = snapshot.tintIcons;
        theme.enableCorners = snapshot.enableCorners;
        theme.animDuration = snapshot.animDuration;
        theme.shadowOpacity = snapshot.shadowOpacity;
        theme.shadowColor = snapshot.shadowColor;
        theme.shadowXOffset = snapshot.shadowXOffset;
        theme.shadowYOffset = snapshot.shadowYOffset;
        theme.shadowBlur = snapshot.shadowBlur;
        
        // Restore SR variants
        var variants = ["srBg", "srInternalBg", "srBarBg", "srPane", "srCommon", "srFocus",
                       "srPrimary", "srPrimaryFocus", "srOverPrimary",
                       "srSecondary", "srSecondaryFocus", "srOverSecondary",
                       "srTertiary", "srTertiaryFocus", "srOverTertiary",
                       "srError", "srErrorFocus", "srOverError"];
        
        for (var i = 0; i < variants.length; i++) {
            var name = variants[i];
            var src = snapshot[name];
            var dest = theme[name];
            
            dest.gradient = JSON.parse(JSON.stringify(src.gradient));
            dest.gradientType = src.gradientType;
            dest.gradientAngle = src.gradientAngle;
            dest.gradientCenterX = src.gradientCenterX;
            dest.gradientCenterY = src.gradientCenterY;
            dest.halftoneDotMin = src.halftoneDotMin;
            dest.halftoneDotMax = src.halftoneDotMax;
            dest.halftoneStart = src.halftoneStart;
            dest.halftoneEnd = src.halftoneEnd;
            dest.halftoneDotColor = src.halftoneDotColor;
            dest.halftoneBackgroundColor = src.halftoneBackgroundColor;
            dest.border = JSON.parse(JSON.stringify(src.border));
            dest.itemColor = src.itemColor;
            dest.opacity = src.opacity;
        }
    }

    function markThemeChanged() {
        // Take a snapshot before the first change
        if (!themeHasChanges) {
            themeSnapshot = createThemeSnapshot();
            Config.pauseAutoSave = true;
        }
        themeHasChanges = true;
    }

    function applyThemeChanges() {
        if (themeHasChanges) {
            Config.loader.writeAdapter();
            themeHasChanges = false;
            themeSnapshot = null;
            Config.pauseAutoSave = false;
        }
    }

    function discardThemeChanges() {
        if (themeHasChanges && themeSnapshot) {
            restoreThemeSnapshot(themeSnapshot);
            themeHasChanges = false;
            themeSnapshot = null;
            Config.pauseAutoSave = false;
        }
    }
}
