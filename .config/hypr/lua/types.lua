---@class HyprlandDSP
---@field exec_once fun(cmd: string): any
---@field exec_cmd fun(cmd: string): any
---@field focus fun(args: table): table
---@field layout fun(layout: string): table
---@field window table
---@field env fun(args: table)

---@class HyprlandAPI
---@field config fun(args: table)
---@field bind fun(key: string, action: table|string, options?: table)
---@field general fun(args: table)
---@field monitor fun(args: table)
---@field env fun(args: table)
---@field dsp HyprlandDSP

-- Declaración global para que el LSP reconozca `hl` en el editor.
---@type HyprlandAPI
_G.hl = _G.hl or {}

-- Archivo solo para anotaciones (EmmyLua). Requerir para que el LSP reconozca los tipos.
return true
