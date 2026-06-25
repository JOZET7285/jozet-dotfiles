local function launch_services()
    local services = {"/usr/bin/waybar", "/usr/bin/quickshell"}
    
    for _, service in ipairs(services) do
        -- Debugging: imprime en el log de hyprland para verificar si entra al loop
        print("Intentando lanzar: " .. service)
        hl.dsp.exec_cmd(service)
    end
end

launch_services()

run_if_not_running("quickshell", "quickshell -s ~/.config/quickshell/main.qml")
run_if_not_running("waybar", "waybar")
hl.dsp.exec_cmd("hyprpaper")
hl.dsp.exec_cmd("nm-applet --indicator")
hl.dsp.exec_cmd("pipewire")
hl.dsp.exec_cmd("wireplumber")

hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_THEME", "capitaine-cursors")
