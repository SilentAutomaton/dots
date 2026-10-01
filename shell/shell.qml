//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import "modules/common"
import "services"

import QtQuick
import Quickshell
import qs.modules.panels.background
import qs.modules.panels.bar
import qs.modules.panels.lock
import qs.modules.panels.mediaControls
import qs.modules.panels.onScreenDisplay
import qs.modules.panels.overview
import qs.modules.panels.polkit
import qs.modules.panels.regionSelector
import qs.modules.panels.screenCorners
import qs.modules.panels.sessionScreen
import qs.modules.panels.sidebarLeft
import qs.modules.panels.sidebarRight
import qs.modules.panels.verticalBar
import qs.modules.panels.wallpaperSelector

ShellRoot {
    ReloadPopup {}

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Hyprsunset.load()
        Cliphist.refresh()
        Wallpapers.load()
    }

    component PanelLoader: LazyLoader {
        property bool extraCondition: true
        active: Config.ready && extraCondition
    }

    PanelLoader { extraCondition: !Config.options.bar.vertical; component: Bar {} }
    PanelLoader { extraCondition: Config.options.bar.vertical; component: VerticalBar {} }
    PanelLoader { component: Background {} }
    PanelLoader { component: Lock {} }
    PanelLoader { component: MediaControls {} }
    PanelLoader { component: OnScreenDisplay {} }
    PanelLoader { component: Overview {} }
    PanelLoader { component: Polkit {} }
    PanelLoader { component: RegionSelector {} }
    PanelLoader { component: ScreenCorners {} }
    PanelLoader { component: SessionScreen {} }
    PanelLoader { component: SidebarLeft {} }
    PanelLoader { component: SidebarRight {} }
    PanelLoader { component: WallpaperSelector {} }
}
