import Jozet.System 1.0
pragma Singleton
import QtQuick

QtObject {
    id: themeRoot

    readonly property bool isDark: {
        try {
            return SystemManager.riceSettings.theme.mode !== "light"
        } catch(e) {
            return true
        }
    }

    // --- Dark palette ---
    readonly property color dark_1: '#d81a1a1a'
    readonly property color dark_1_solid: '#1a1a1a'
    readonly property color dark_2: '#d82b2b2b'
    readonly property color dark_2_solid: '#2b2b2b'
    readonly property color dark_3: '#d83c3c3c'
    readonly property color dark_3_solid: '#3c3c3c'
    readonly property color dark_4: '#d84d4d4d'
    readonly property color dark_4_solid: '#4d4d4d'

    // --- Light palette ---
    readonly property color light_1: '#d8f4f4f4'
    readonly property color light_1_solid: '#f4f4f4'
    readonly property color light_2: '#d8d3d3d3'
    readonly property color light_2_solid: '#d3d3d3'
    readonly property color light_3: '#d8b2b2b2'
    readonly property color light_3_solid: '#b2b2b2'
    readonly property color light_4: '#d8a1a1a1'
    readonly property color light_4_solid: '#d8a1a1a1'

    // --- Active base colors ---
    readonly property color color_1: isDark ? dark_1 : light_1
    readonly property color color_1_solid: isDark ? dark_1_solid : light_1_solid
    readonly property color color_2: isDark ? dark_2 : light_2
    readonly property color color_2_solid: isDark ? dark_2_solid : light_2_solid
    readonly property color color_3: isDark ? dark_3 : light_3
    readonly property color color_3_solid: isDark ? dark_3_solid : light_3_solid
    readonly property color color_4: isDark ? dark_4 : light_4
    readonly property color color_4_solid: isDark ? dark_4_solid : light_4_solid

    // --- Accent colors (same for both themes) ---
    readonly property color color_b: '#d887edff'
    readonly property color color_b_solid: '#87edff'
    readonly property color color_b_accent: '#4ac6ff'
    readonly property color color_b_dark: '#d85787ff'

    readonly property color color_p: '#d8c987ff'
    readonly property color color_p_solid: '#bb87ff'
    readonly property color color_p_accent: '#bd4aff'
    readonly property color color_p_dark: '#ee00ff'

    readonly property color color_g: '#d8a7ff87'
    readonly property color color_g_solid: '#afff92'
    readonly property color color_g_accent: '#46ff40'
    readonly property color color_g_dark: '#06ab00'

    readonly property color color_y: '#d8ffe987'
    readonly property color color_y_solid: '#f4ff92'
    readonly property color color_y_accent: '#f0ff65'
    readonly property color color_y_dark: '#ffbb00'

    readonly property color color_o: '#d8ffae78'
    readonly property color color_o_solid: '#ffae78'
    readonly property color color_o_accent: '#ff8045'
    readonly property color color_o_dark: '#ff4d00'

    readonly property color color_r: '#d8ff4d4d'
    readonly property color color_r_solid: '#ff4d4d'
    readonly property color color_r_accent: '#ff2d2d'
    readonly property color color_r_dark: '#ff0000'

    // --- Text color ---
    readonly property color text_color: isDark ? '#fff' : '#1a1a1a'
    readonly property color text_color_secondary: isDark ? '#aaa' : '#555'

    readonly property color color_y_text: isDark ? color_y_solid : color_y_dark
    readonly property color color_b_text: isDark ? color_b_solid : color_b_dark
    readonly property color color_g_text: isDark ? color_g_solid : color_g_dark
    readonly property color color_o_text: isDark ? color_o_solid : color_o_dark
    readonly property color color_r_text: isDark ? color_r_solid : color_r_dark
    readonly property color color_p_text: isDark ? color_p_solid : color_p_dark
    readonly property color color_matugen: SystemManager.matugenColors.accent || color_b_solid

    readonly property color color_a_text: {
        switch (SystemManager.riceSettings.theme.accent_color) {
            case "y": return isDark ? color_y_solid : color_y_dark
            case "b": return isDark ? color_b_solid : color_b_dark
            case "g": return isDark ? color_g_solid : color_g_dark
            case "o": return isDark ? color_o_solid : color_o_dark
            case "r": return isDark ? color_r_solid : color_r_dark
            case "p": return isDark ? color_p_solid : color_p_dark
            case "bw": return text_color
            case "m": return color_matugen
            default: return color_b_solid
        }
    }

    // --- Layout / Typography ---
    readonly property int radius: 12
    readonly property int height: 35
    readonly property real referenceWidth: 1920
    readonly property string fontName: "Inter"
    readonly property string iconFont: "Font Awesome 7 Free"
}
