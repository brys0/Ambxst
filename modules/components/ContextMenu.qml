import QtQuick
import QtQuick.Controls
import Quickshell
import qs.modules.theme
import qs.modules.components
import qs.config

OptionsMenu {
    id: root

    required property var menuHandle
    property bool isOpen: false

    // Configuración específica para menús contextuales
    menuWidth: 160
    itemHeight: 32

    // Opener para acceder a los hijos del QsMenuHandle
    QsMenuOpener {
        id: menuOpener
        menu: root.menuHandle
        
        onChildrenChanged: {
            console.log("Menu children changed, count:", children ? children.values.length : "null");
        }
    }

    // Convertir los QsMenuEntry a formato compatible con OptionsMenu
    items: {
        console.log("Building menu items...");
        console.log("menuHandle:", root.menuHandle);
        console.log("menuOpener.children:", menuOpener.children);
        
        if (!menuOpener.children || !menuOpener.children.values) {
            console.log("No children values available");
            return [];
        }
        
        let menuItems = [];
        console.log("Children count:", menuOpener.children.values.length);
        
        for (let i = 0; i < menuOpener.children.values.length; i++) {
            let entry = menuOpener.children.values[i];
            console.log("Entry", i, ":", entry, "text:", entry ? entry.text : "null");
            if (entry) {
                menuItems.push({
                    text: entry.text || "Menu Item " + i,
                    icon: entry.icon || "",
                    enabled: entry.enabled !== false,
                    onTriggered: function() {
                        console.log("Triggering menu item:", entry.text);
                        if (entry.triggered) {
                            entry.triggered();
                        }
                        root.close();
                    }
                });
            }
        }
        console.log("Final menu items count:", menuItems.length);
        return menuItems;
    }

    // Funciones de control
    function open() {
        console.log("Opening context menu...");
        console.log("menuHandle:", menuHandle);
        console.log("Has menu:", !!menuHandle);
        
        isOpen = true;
        popup();
    }

    function close() {
        console.log("Closing context menu");
        isOpen = false;
        visible = false;
    }
}