local s = require("lua.datos")

hl.config({
  input = {
    kb_layout = s.kb_layout,
    touchpad = {
      natural_scroll = true
    },
  },

  general = {
    gaps_in = s.gaps_in,
    gaps_out = s.gaps_out,
  },

  decoration = {
    blur = {
      enabled = true,
      size = 9,
      passes = 3,
      new_optimizations = true,
      xray = true,
    },
  },
})
