pragma Singleton
import QtQuick

QtObject {
    readonly property color bg_1: "#2b2b2b"
    readonly property color bg_2: "#1a1a1a"
    readonly property color bg_hover: "#3c3c3c"
    readonly property color accent: "#5e9eff"
    readonly property int radius: 12
    readonly property int height: 35
    readonly property color text_color: "#ffffff"
    readonly property color text_dim: "#9a9a9a"
    readonly property color border_color: "#3c3c3c"
    readonly property string fontName: "Inter"

    // Requires a Nerd Font installed, e.g. `ttf-nerd-fonts-symbols-mono` on Arch.
    // Change this if you use a different Nerd Font variant/name.
    readonly property string iconFont: "Symbols Nerd Font Mono"
}
