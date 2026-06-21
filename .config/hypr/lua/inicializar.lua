require("lua.types")
---@type HyprlandAPI
local hl = _G.hl or error("Hyprland API 'hl' no disponible")

hl.dsp.exec_once("waybar")
hl.dsp.exec_once("hyprpaper")
hl.dsp.exec_once("nm-applet --indicator")
hl.dsp.exec_once("pipewire")
hl.dsp.exec_once("wireplumber")


hl.env({
    XCURSOR_SIZE = "16",
    HYPRCURSOR_THEME = "capitaine-cursors",
})