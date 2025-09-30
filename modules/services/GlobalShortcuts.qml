import QtQuick
import Quickshell.Hyprland._GlobalShortcuts
import qs.modules.globals
import qs.modules.services

Item {
    id: root

    GlobalShortcut {
        id: overviewShortcut
        appid: "ambxst"
        name: "overview"
        description: "Toggle window overview"

        onPressed: {
            console.log("Overview shortcut pressed");

            // Toggle overview - if already open, close it; otherwise open overview
            if (Visibilities.currentActiveModule === "overview") {
                Visibilities.setActiveModule("");
            } else {
                Visibilities.setActiveModule("overview");
            }
        }
    }

    GlobalShortcut {
        id: powermenuShortcut
        appid: "ambxst"
        name: "powermenu"
        description: "Toggle power menu"

        onPressed: {
            console.log("Power menu shortcut pressed");

            // Toggle power menu - if already open, close it; otherwise open power menu
            if (Visibilities.currentActiveModule === "powermenu") {
                Visibilities.setActiveModule("");
            } else {
                Visibilities.setActiveModule("powermenu");
            }
        }
    }

    // Launcher tab shortcuts
    GlobalShortcut {
        id: launcherAppsShortcut
        appid: "ambxst"
        name: "launcher-apps"
        description: "Open launcher apps tab"

        onPressed: {
            console.log("Launcher apps shortcut pressed");

            // Toggle si ya está en launcher con apps tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "launcher" && GlobalStates.launcherCurrentTab === 0) {
                GlobalStates.clearLauncherState();
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "launcher") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.launcherCurrentTab = 0;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.launcherCurrentTab = 0;
                Visibilities.setActiveModule("launcher");
            }
        }
    }

    GlobalShortcut {
        id: launcherTmuxShortcut
        appid: "ambxst"
        name: "launcher-tmux"
        description: "Open launcher tmux tab"

        onPressed: {
            console.log("Launcher tmux shortcut pressed");

            // Toggle si ya está en launcher con tmux tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "launcher" && GlobalStates.launcherCurrentTab === 1) {
                GlobalStates.clearLauncherState();
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "launcher") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.launcherCurrentTab = 1;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.launcherCurrentTab = 1;
                Visibilities.setActiveModule("launcher");
            }
        }
    }

    GlobalShortcut {
        id: launcherClipboardShortcut
        appid: "ambxst"
        name: "launcher-clipboard"
        description: "Open launcher clipboard tab"

        onPressed: {
            console.log("Launcher clipboard shortcut pressed");

            // Toggle si ya está en launcher con clipboard tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "launcher" && GlobalStates.launcherCurrentTab === 2) {
                GlobalStates.clearLauncherState();
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "launcher") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.launcherCurrentTab = 2;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.launcherCurrentTab = 2;
                Visibilities.setActiveModule("launcher");
            }
        }
    }

    // Dashboard tab shortcuts
    GlobalShortcut {
        id: dashboardWidgetsShortcut
        appid: "ambxst"
        name: "dashboard-widgets"
        description: "Open dashboard widgets tab"

        onPressed: {
            console.log("Dashboard widgets shortcut pressed");

            // Toggle si ya está en dashboard con widgets tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "dashboard" && GlobalStates.dashboardCurrentTab === 0) {
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "dashboard") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.dashboardCurrentTab = 0;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.dashboardCurrentTab = 0;
                Visibilities.setActiveModule("dashboard");
            }
        }
    }

    GlobalShortcut {
        id: dashboardPinsShortcut
        appid: "ambxst"
        name: "dashboard-pins"
        description: "Open dashboard pins tab"

        onPressed: {
            console.log("Dashboard pins shortcut pressed");

            // Toggle si ya está en dashboard con pins tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "dashboard" && GlobalStates.dashboardCurrentTab === 1) {
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "dashboard") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.dashboardCurrentTab = 1;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.dashboardCurrentTab = 1;
                Visibilities.setActiveModule("dashboard");
            }
        }
    }

    GlobalShortcut {
        id: dashboardKanbanShortcut
        appid: "ambxst"
        name: "dashboard-kanban"
        description: "Open dashboard kanban tab"

        onPressed: {
            console.log("Dashboard kanban shortcut pressed");

            // Toggle si ya está en dashboard con kanban tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "dashboard" && GlobalStates.dashboardCurrentTab === 2) {
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "dashboard") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.dashboardCurrentTab = 2;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.dashboardCurrentTab = 2;
                Visibilities.setActiveModule("dashboard");
            }
        }
    }

    GlobalShortcut {
        id: dashboardWallpapersShortcut
        appid: "ambxst"
        name: "dashboard-wallpapers"
        description: "Open dashboard wallpapers tab"

        onPressed: {
            console.log("Dashboard wallpapers shortcut pressed");

            // Toggle si ya está en dashboard con wallpapers tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "dashboard" && GlobalStates.dashboardCurrentTab === 3) {
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "dashboard") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.dashboardCurrentTab = 3;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.dashboardCurrentTab = 3;
                Visibilities.setActiveModule("dashboard");
            }
        }
    }

    GlobalShortcut {
        id: dashboardAssistantShortcut
        appid: "ambxst"
        name: "dashboard-assistant"
        description: "Open dashboard assistant tab"

        onPressed: {
            console.log("Dashboard assistant shortcut pressed");

            // Toggle si ya está en dashboard con assistant tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "dashboard" && GlobalStates.dashboardCurrentTab === 4) {
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "dashboard") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.dashboardCurrentTab = 4;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.dashboardCurrentTab = 4;
                Visibilities.setActiveModule("dashboard");
            }
        }
    }

    GlobalShortcut {
        id: launcherEmojiShortcut
        appid: "ambxst"
        name: "launcher-emoji"
        description: "Open launcher emoji tab"

        onPressed: {
            console.log("Launcher emoji shortcut pressed");

            // Toggle si ya está en launcher con emoji tab, sino abrir/navegar
            if (Visibilities.currentActiveModule === "launcher" && GlobalStates.launcherCurrentTab === 3) {
                GlobalStates.clearLauncherState();
                Visibilities.setActiveModule("");
            } else if (Visibilities.currentActiveModule === "launcher") {
                // Solo navegar a la pestaña sin cerrar/abrir
                GlobalStates.launcherCurrentTab = 3;
            } else {
                // Actualizar la pestaña ANTES de abrir el módulo
                GlobalStates.launcherCurrentTab = 3;
                Visibilities.setActiveModule("launcher");
            }
        }
    }
}
