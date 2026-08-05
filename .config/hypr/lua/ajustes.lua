package.path = package.path .. ";" .. os.getenv("HOME") .. "/.local/share/jzt/?.lua"
local s = require("datos")

local speed = s.cursor_speed
if speed == nil or speed <= 0 then speed = 1.0 end

hl.env("XCURSOR_SIZE", tostring(s.cursor_size))
hl.env("HYPRCURSOR_SIZE", tostring(s.cursor_size))
if s.cursor_theme ~= nil and s.cursor_theme ~= "" then
  hl.env("XCURSOR_THEME", s.cursor_theme)
  hl.env("HYPRCURSOR_THEME", s.cursor_theme)
end

hl.config({
  input = {
    kb_layout = s.kb_layout,
    sensitivity = speed,
    touchpad = {
      natural_scroll = true
    },
  },

  general = {
    gaps_in = s.gaps_in,
    gaps_out = s.gaps_out,
    border_size = s.border_size,
    ["col.active_border"] = s.active_border,
    ["col.inactive_border"] = s.inactive_border,
  },

  decoration = {
    rounding = s.border_radius,
    blur = {
      enabled = true,
      size = 9,
      passes = 3,
      new_optimizations = true,
      xray = true,
    },
  },
})
