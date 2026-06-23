require("lua/inicializar")
require("lua/monitores")
require("lua/combinaciones")
require("lua/window_rules")

hl.window_rule({
    name = "general",
    match = {
    	class = all
    },
    rounding = 10
})
