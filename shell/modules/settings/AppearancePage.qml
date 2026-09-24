import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

SettingsPage {
    id: page
    property string wallpaperScheme: "scheme-tonal-spot"

    FolderListModel {
        id: palettes
        folder: Qt.resolvedUrl(`${Directories.themeDir}/palettes`)
        nameFilters: ["*.sh"]
        showDirs: false
    }
    FileView {
        id: currentPalette
        path: `${FileUtils.trimFileProtocol(Directories.genericState)}/theme/name`
        watchChanges: true
        onFileChanged: reload()
    }

    function paletteName(fileName) {
        return fileName.replace(/\.sh$/, "").split("-").map(word => word[0].toUpperCase() + word.slice(1)).join(" ");
    }

    SettingsSection {
        icon: "palette"
        title: "Theme"

        SettingsLabel {
            text: "Palette for the shell, Hyprland, terminals, editors and toolkits"
        }
        ConfigSelectionArray {
            currentValue: currentPalette.text().trim() || "tomorrow-night"
            onSelected: name => Quickshell.execDetached([`${Directories.themeDir}/apply`, name])
            options: Array.from({ length: palettes.count }, (_, i) => {
                const fileName = palettes.get(i, "fileName");
                return { "displayName": page.paletteName(fileName), "value": fileName.replace(/\.sh$/, "") };
            })
        }

        SettingsLabel {
            text: "Generate a palette from the current wallpaper"
        }
        ConfigSelectionArray {
            currentValue: page.wallpaperScheme
            onSelected: scheme => page.wallpaperScheme = scheme
            options: [
                { "displayName": "Tonal spot", "value": "scheme-tonal-spot" },
                { "displayName": "Neutral", "value": "scheme-neutral" },
                { "displayName": "Monochrome", "value": "scheme-monochrome" },
                { "displayName": "Content", "value": "scheme-content" },
                { "displayName": "Expressive", "value": "scheme-expressive" }
            ]
        }
        RippleButtonWithIcon {
            Layout.leftMargin: 8
            materialIcon: "auto_awesome"
            mainText: "Generate and apply"
            onClicked: Quickshell.execDetached([`${Directories.themeDir}/from-wallpaper`, Config.options.background.wallpaperPath, page.wallpaperScheme])
        }
    }

    SettingsSection {
        icon: "wallpaper"
        title: "Wallpaper"

        ConfigSelectionArray {
            currentValue: Config.options.background.mode
            onSelected: mode => Config.options.background.mode = mode
            options: [
                { "displayName": "Image", "value": "image" },
                { "displayName": "Matrix news", "value": "matrix" }
            ]
        }
        RippleButtonWithIcon {
            Layout.leftMargin: 8
            visible: MatrixWallpaper.active
            enabled: !MatrixWallpaper.refreshing
            materialIcon: "sync"
            mainText: MatrixWallpaper.refreshing ? "Fetching news…" : "Refresh news"
            onClicked: MatrixWallpaper.refreshNews()
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            StyledImage {
                id: preview
                Layout.preferredWidth: 280
                Layout.preferredHeight: 158
                fillMode: Image.PreserveAspectCrop
                source: Config.options.background.wallpaperPath
                cache: false
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: preview.width
                        height: preview.height
                        radius: Appearance.rounding.normal
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: FileUtils.fileNameForPath(Config.options.background.wallpaperPath)
                    elide: Text.ElideMiddle
                    color: Appearance.colors.colOnLayer1
                }
                RippleButtonWithIcon {
                    materialIcon: "photo_library"
                    mainText: "Choose wallpaper"
                    onClicked: Quickshell.execDetached(["qs", "-c", "shell", "ipc", "call", "wallpaperSelector", "toggle"])
                }
                ConfigSwitch {
                    text: "Use the system file dialog"
                    checked: Config.options.wallpaperSelector.useSystemFileDialog
                    onCheckedChanged: Config.options.wallpaperSelector.useSystemFileDialog = checked
                }
            }
        }

        SettingsLabel {
            text: "Parallax"
        }
        ConfigSwitch {
            buttonIcon: "view_week"
            text: "Shift with the workspace"
            checked: Config.options.background.parallax.enableWorkspace
            onCheckedChanged: Config.options.background.parallax.enableWorkspace = checked
        }
        ConfigSwitch {
            buttonIcon: "side_navigation"
            text: "Shift when a sidebar opens"
            checked: Config.options.background.parallax.enableSidebar
            onCheckedChanged: Config.options.background.parallax.enableSidebar = checked
        }
        ConfigSpinBox {
            icon: "loupe"
            text: "Zoom (%)"
            value: Math.round(Config.options.background.parallax.workspaceZoom * 100)
            from: 100
            to: 150
            stepSize: 1
            onValueChanged: Config.options.background.parallax.workspaceZoom = value / 100
        }
    }

    SettingsSection {
        icon: "opacity"
        title: "Transparency"

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: "Translucent panels"
            checked: Config.options.appearance.transparency.enable
            onCheckedChanged: Config.options.appearance.transparency.enable = checked
        }
        ConfigSpinBox {
            enabled: Config.options.appearance.transparency.enable
            icon: "gradient"
            text: "Panel transparency (%)"
            value: Math.round(Config.options.appearance.transparency.backgroundTransparency * 100)
            from: 0
            to: 90
            stepSize: 5
            onValueChanged: Config.options.appearance.transparency.backgroundTransparency = value / 100
        }
        ConfigSpinBox {
            enabled: Config.options.appearance.transparency.enable
            icon: "layers"
            text: "Content transparency (%)"
            value: Math.round(Config.options.appearance.transparency.contentTransparency * 100)
            from: 0
            to: 90
            stepSize: 5
            onValueChanged: Config.options.appearance.transparency.contentTransparency = value / 100
        }
    }

    SettingsSection {
        icon: "rounded_corner"
        title: "Shape"

        SettingsLabel {
            text: "Bar style"
        }
        ConfigSelectionArray {
            currentValue: Config.options.bar.cornerStyle
            onSelected: value => Config.options.bar.cornerStyle = value
            options: [
                { "displayName": "Hug", "icon": "line_curve", "value": 0 },
                { "displayName": "Float", "icon": "page_header", "value": 1 },
                { "displayName": "Rectangle", "icon": "toolbar", "value": 2 }
            ]
        }
        SettingsLabel {
            text: "Rounded screen corners"
        }
        ConfigSelectionArray {
            currentValue: Config.options.appearance.fakeScreenRounding
            onSelected: value => Config.options.appearance.fakeScreenRounding = value
            options: [
                { "displayName": "Off", "icon": "close", "value": 0 },
                { "displayName": "Always", "icon": "check", "value": 1 },
                { "displayName": "Except fullscreen", "icon": "fullscreen_exit", "value": 2 }
            ]
        }
    }

    SettingsSection {
        icon: "font_download"
        title: "Fonts"

        SettingsTextField {
            icon: "text_fields"
            text: "Interface"
            value: Config.options.appearance.fonts.main
            onAccepted: value => {
                Config.options.appearance.fonts.main = value;
                Config.options.appearance.fonts.numbers = value;
                Config.options.appearance.fonts.iconNerd = value;
            }
        }
        SettingsTextField {
            icon: "title"
            text: "Titles"
            value: Config.options.appearance.fonts.title
            onAccepted: value => Config.options.appearance.fonts.title = value
        }
        SettingsTextField {
            icon: "code"
            text: "Monospace"
            value: Config.options.appearance.fonts.monospace
            onAccepted: value => Config.options.appearance.fonts.monospace = value
        }
    }
}
