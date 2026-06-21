require("lua.types")
---@type HyprlandAPI
local hl = _G.hl or error("Hyprland API 'hl' no disponible")

require("lua.inicializar")
require("lua.monitores")
require("lua.combinaciones")

hl.general({ border_size = 2 })