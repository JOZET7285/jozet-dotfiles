hl.on("hyprland.start", function ()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("QML2_IMPORT_PATH=/home/jozet/jozet-dotfiles/backend/build quickshell")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("systemctl --user restart pipewire pipewire-pulse wireplumber")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swayosd-server --style " .. os.getenv("HOME") .. "/.config/swayosd/style.css")
end)

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.local/share/jzt/config/?.lua"

local ok, datos = pcall(require, "datos")
if not ok then
    datos = {
        gaps_in = 5,
        gaps_out = 15,
        border_radius = 8,
        border_size = 2,
        kb_layout = "latam",
        cursor_theme = "Bibata-Modern-Ice",
        cursor_size = 24,
        cursor_speed = 0.0,
    }
end
