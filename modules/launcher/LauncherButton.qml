import QtQuick
import qs.modules.globals
import qs.config

ToggleButton {
    buttonIcon: Config.bar.launcherIcon
    tooltipText: "Open Application Launcher"

    onToggle: function () {
        if (GlobalStates.launcherOpen) {
            GlobalStates.launcherOpen = false;
        } else {
            GlobalStates.dashboardOpen = false;
            GlobalStates.overviewOpen = false;
            GlobalStates.launcherOpen = true;
        }
    }
}
