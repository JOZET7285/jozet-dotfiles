pragma Singleton
import QtQuick

QtObject {
    readonly property color bg_1: '#c42b2b2b'
    readonly property color bg_2: '#c41a1a1a'
    readonly property color bg_3: '#c43c3c3c'
    readonly property color bg_light_1: '#9f9f9f' 
    readonly property color bg_2_solid: '#1a1a1a'
    readonly property color bg_hover: "#3c3c3c"
    readonly property color accent: '#71fffa'

    readonly property color btn_color: '#a0b3fffc' 
    readonly property color btn_accent_color: '#c6b3fffc' 
    readonly property color btn_selected_color: '#ffb3fffc'
    readonly property color btn_text_color: '#1a1a1a' 
    readonly property color btn_text_color_light: '#f1f1f1'
    readonly property int radius: 12
    readonly property int height: 35
    readonly property color text_color: "#ffffff" 
    readonly property color text_dim: "#9a9a9a"
    readonly property color border_color: "#3c3c3c"
    readonly property color border_color_2: "#9a9a9a"
    readonly property string fontName: "Inter"

    // Requires a Nerd Font installed, e.g. `ttf-nerd-fonts-symbols-mono` on Arch.
    // Change this if you use a different Nerd Font variant/name.
    readonly property string iconFont: "Font Awesome 7 Free"
}
