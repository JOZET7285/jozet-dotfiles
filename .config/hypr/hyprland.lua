local config_dir = os.getenv("HOME") .. "/.config/hypr/"
dofile(config_dir .. "lua/inicializar.lua")
dofile(config_dir .. "lua/monitores.lua")
dofile(config_dir .. "lua/combinaciones.lua")
dofile(config_dir .. "lua/window_rules.lua")

hl.config({
    input = {
        kb_layout = "latam",
    }
})

gaps_in = 2
gaps_out = 2
