package.path = package.path .. ";" .. os.getenv("HOME") .. "/.local/share/jzt/datos.lua"
local s = require("datos")

hl.window_rule({
    name = "general",
    match = { class = "negative:^quickshell$" },
    border_size = s.border_size,
    rounding = s.border_radius,
    animation = "popin",
})

hl.layer_rule({
    match = "lockscreen",
    blur = true,
    ignore_alpha = 0.1,
})

-- ───────── Spotify ─────────

hl.window_rule({
    name = "spotify_transparence",
    match = { class = "^Spotify$" },
    opacity = "0.85 0.80"
})

hl.window_rule({
    name = "spotify_rule",
    match = { title = "^Spotify$" },
    float = true,
    size = "70% 70%",
    center = true
})

-- ───────── Floorp ─────────

hl.window_rule({
    name = "floorp_transparence",
    match = { class = "^floorp$" },
    opacity = "0.9 0.85"
})
