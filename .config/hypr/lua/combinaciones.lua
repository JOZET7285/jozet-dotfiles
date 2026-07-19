-- KEYBINDIGS --
mainMod = "SUPER" 

-- Lanzadores y sistema
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("sh -c 'monitor=$(hyprctl activeworkspace -j | jq -r .monitor); qs ipc call bluetoothPopup-$monitor toggle'"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("sh -c 'monitor=$(hyprctl activeworkspace -j | jq -r .monitor); qs ipc call appLauncher-$monitor toggle'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("floorp"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch exit")) 
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("sh -c 'monitor=$(hyprctl activeworkspace -j | jq -r .monitor); qs ipc call networkPopup-$monitor toggle'"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("sh -c 'monitor=$(hyprctl activeworkspace -j | jq -r .monitor); qs ipc call todayPopup-$monitor toggle'"))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("sh -c 'monitor=$(hyprctl activeworkspace -j | jq -r .monitor); qs ipc call workspacesPopup-$monitor toggle'"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("sh -c 'monitor=$(hyprctl activeworkspace -j | jq -r .monitor); qs ipc call wallpaperSelector-$monitor toggle'"))

-- Ventanas
hl.bind(mainMod .. " + C", hl.dsp.window.kill(active))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("quickshell-client --name quickshell --send toggle"))

-- Movimiento de foco
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces (Ciclo automático)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Multimedia
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })

-- Sistema
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +2%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 2%-"))

-- Atajos
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
