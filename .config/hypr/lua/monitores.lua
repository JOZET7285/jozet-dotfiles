require("lua.types")
---@type HyprlandAPI
local hl = _G.hl or error("Hyprland API 'hl' no disponible")

hl.monitor({
    name = "Virtual-1",
    resolution = "1920x1080@60",
    position = "0x0",
    scale = "1"
})
hl.monitor({ 
    name = "HDMI-A-1", 
    resolution = "1920x1080@60", 
    position = "2560x0", 
    scale = "1" })