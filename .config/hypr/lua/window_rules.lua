
hl.window_rule({
    name = "general",
    match = { class = "negative:^quickshell$" },    
    border_size = 1,
    rounding = 6,
    animation = "popin",
})

hl.layer_rule({
    match = "lockscreen",
    blur = true,
    ignore_alpha = 0.1,
})
