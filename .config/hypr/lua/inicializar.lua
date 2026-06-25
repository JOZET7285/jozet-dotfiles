local function run_if_not_running(process_name, command)
    local handle = io.popen("pgrep -x " .. process_name)
    local result = handle:read("*a")
    handle:close()

    if result == "" then
        hl.dsp.exec_cmd(command)
    end
end

run_if_not_running("quickshell", "quickshell -s ~/.config/quickshell/main.qml")
run_if_not_running("waybar", "waybar")
hl.dsp.exec_cmd("hyprpaper")
hl.dsp.exec_cmd("nm-applet --indicator")
hl.dsp.exec_cmd("pipewire")
hl.dsp.exec_cmd("wireplumber")

hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_THEME", "capitaine-cursors")
