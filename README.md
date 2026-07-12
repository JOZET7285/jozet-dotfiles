# jozet-dotfiles

Mi configuración de Hyprland: un panel/status bar propio hecho con **Quickshell**, respaldado por un plugin de Qt6/C++ que lee el estado real del sistema (red, bluetooth, volumen, batería, temperatura, CPU/RAM).

## Stack

- **Hyprland** (0.55+, config en Lua nativo)
- **Quickshell** — el panel, en QML
- **Qt6 / C++** — plugin `Jozet.System` que expone el estado del sistema a QML vía D-Bus, `/sys`, `/proc` y llamadas a herramientas como `nmcli`, `pactl`, `playerctl`
- **kitty**, **neovim**, **awww** (wallpapers)

## Estructura

```
.
├── backend/                   # Plugin Qt6/C++ (JozetPlugin, URI Jozet.System)
│   ├── CMakeLists.txt
│   └── System/
│       ├── SystemManager.{h,cpp}      # Fachada expuesta a QML
│       └── Readers/                   # Un reader por subsistema
│           ├── CpuReader, RamReader, DiskReader, TempReader
│           ├── NetworkReader, BluetoothReader, VolumeReader
├── .config/
│   ├── hypr/                  # Config de Hyprland (Lua)
│   ├── quickshell/            # Panel (QML)
│   │   ├── Islands/           # Contenedores principales del panel
│   │   ├── Modules/           # Widgets funcionales (red, volumen, energía...)
│   │   ├── Popups/            # Paneles desplegables
│   │   ├── Components/        # Piezas reutilizables (botones, pills, tema)
│   │   └── Widgets/           # Wallpaper, referencias globales
│   ├── kitty/
│   └── nvim/
├── home/.zshrc
└── install.sh                 # Instalador
```

## Instalación

Requiere Arch Linux (o derivada).

```bash
git clone https://github.com/JOZET7285/jozet-dotfiles.git
cd jozet-dotfiles
./install.sh
```

El script:
1. Instala dependencias (Hyprland, Quickshell, Qt6, herramientas de red/audio/bluetooth, etc.)
2. Hace symlink de las configs a `~/.config/*` (con backup automático de lo que ya tengas)
3. Compila el plugin de Qt (`backend/build`)
4. Ajusta la ruta del plugin en la config de Hyprland
5. Habilita los servicios necesarios (PipeWire, NetworkManager, Bluetooth)

Al terminar, cierra sesión y entra a Hyprland desde tu display manager.

## Desarrollo del backend

```bash
cmake -S backend -B backend/build
cmake --build backend/build -j$(nproc)
```

El módulo QML se genera en `backend/build/Jozet/System`. Quickshell lo encuentra vía `QML2_IMPORT_PATH` (configurado en `.config/hypr/lua/inicializar.lua`).

## Estado

Proyecto personal en desarrollo activo. Hay bugs conocidos y features a medio terminar — no lo tomes como un dotfile "listo para producción" todavía.

## Licencia

Sin licencia definida por ahora — úsalo como referencia, pero no asumas permiso de redistribución.
