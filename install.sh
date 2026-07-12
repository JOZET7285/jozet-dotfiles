#!/usr/bin/env bash
#
# install.sh — instalador de jozet-dotfiles
#
# Requiere Arch Linux (o derivada) con yay disponible o instalable.
# Uso:
#   ./install.sh            instalación normal (con confirmaciones)
#   ./install.sh --yes      no pregunta nada, asume "sí" en todo
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.jozet-dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
ASSUME_YES=false
if [[ "${1:-}" == "--yes" ]]; then 
    ASSUME_YES=true
fi
# paquetes oficiales (repo), todos disponibles vía pacman/yay
PACMAN_PKGS=(
    hyprland qt6-base qt6-declarative quickshell awww capitaine-cursors
    cmake base-devel git
    networkmanager network-manager-applet
    pipewire pipewire-pulse pipewire-alsa wireplumber
    playerctl brightnessctl power-profiles-daemon
    bluez bluez-utils
    kitty neovim zsh
    ttf-jetbrains-mono-nerd
)

# mapa "config en el repo" -> "destino en $HOME"
declare -A LINK_MAP=(
    [".config/hypr"]="$HOME/.config/hypr"
    [".config/quickshell"]="$HOME/.config/quickshell"
    [".config/kitty"]="$HOME/.config/kitty"
    [".config/nvim"]="$HOME/.config/nvim"
    ["home/.zshrc"]="$HOME/.zshrc"
)

# ---------------------------------------------------------------------------
# Utilidades de salida
# ---------------------------------------------------------------------------
c_info="\033[1;34m"; c_ok="\033[1;32m"; c_warn="\033[1;33m"; c_err="\033[1;31m"; c_off="\033[0m"
info()  { echo -e "${c_info}==>${c_off} $*"; }
ok()    { echo -e "${c_ok}  ✓${c_off} $*"; }
warn()  { echo -e "${c_warn}  !${c_off} $*"; }
err()   { echo -e "${c_err}  ✗${c_off} $*" >&2; }
die()   { err "$*"; exit 1; }

confirm() {
    if $ASSUME_YES; then 
        return 0
    fi
    local prompt="$1"
    read -rp "$(echo -e "${c_warn}?${c_off} ${prompt} [s/N] ")" reply
    [[ "$reply" =~ ^[sSyY]$ ]]
}

# ---------------------------------------------------------------------------
# Checks previos
# ---------------------------------------------------------------------------
check_arch() {
    command -v pacman >/dev/null 2>&1 || die "Esto es para Arch Linux (o derivada) — no se encontró pacman."
}

check_not_root() {
    if [[ "$EUID" -eq 0 ]]; then 
        die "No corras este script como root. Usa tu usuario normal (pedirá sudo cuando lo necesite)."
    fi
}

ensure_yay() {
    if command -v yay >/dev/null 2>&1; then
        ok "yay ya está instalado"
        return
    fi
    info "yay no está instalado, lo instalo desde AUR..."
    sudo pacman -S --needed --noconfirm base-devel git
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "yay instalado"
}

# ---------------------------------------------------------------------------
# Instalación de paquetes
# ---------------------------------------------------------------------------
install_packages() {
    info "Instalando paquetes oficiales..."
    yay -S --needed --noconfirm "${PACMAN_PKGS[@]}" \
        || die "Falló la instalación de paquetes oficiales"
    ok "Paquetes oficiales instalados"

    info "Instalando paquetes de AUR..."
    yay -S --needed --noconfirm "${AUR_PKGS[@]}" \
        || die "Falló la instalación de paquetes AUR"
    ok "Paquetes AUR instalados"
}

# ---------------------------------------------------------------------------
# Symlinks con backup
# ---------------------------------------------------------------------------
link_configs() {
    info "Enlazando configuraciones..."
    mkdir -p "$HOME/.config"

    for src_rel in "${!LINK_MAP[@]}"; do
        local src="$REPO_DIR/$src_rel"
        local dst="${LINK_MAP[$src_rel]}"

        [[ -e "$src" ]] || { warn "No existe $src, se salta"; continue; }

        # ya enlazado correctamente -> nada que hacer
        if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
            ok "$dst ya apunta a $src"
            continue
        fi

        # si existe algo (archivo, carpeta o symlink viejo) lo respaldamos
        if [[ -e "$dst" || -L "$dst" ]]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$src_rel")"
            mv "$dst" "$BACKUP_DIR/$src_rel"
            warn "Backup de $dst -> $BACKUP_DIR/$src_rel"
        fi

        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
        ok "Enlazado $dst -> $src"
    done
}

# ---------------------------------------------------------------------------
# Backend Qt (JozetPlugin)
# ---------------------------------------------------------------------------
build_backend() {
    info "Compilando el plugin de Qt (backend)..."
    cmake -S "$REPO_DIR/backend" -B "$REPO_DIR/backend/build" -DCMAKE_BUILD_TYPE=Release \
        || die "cmake falló al configurar el backend"
    cmake --build "$REPO_DIR/backend/build" -j"$(nproc)" \
        || die "Falló la compilación del backend"
    ok "Backend compilado en $REPO_DIR/backend/build"
}

# ---------------------------------------------------------------------------
# Corrige la ruta hardcodeada de QML2_IMPORT_PATH en inicializar.lua
# ---------------------------------------------------------------------------
fix_import_path() {
    local target="$HOME/.config/hypr/lua/inicializar.lua"
    local build_path="$REPO_DIR/backend/build"

    [[ -f "$target" ]] || { warn "No encontré $target, se salta el ajuste de ruta"; return; }

    if grep -q "QML2_IMPORT_PATH=$build_path" "$target"; then
        ok "inicializar.lua ya apunta a la ruta correcta"
        return
    fi

    info "Ajustando QML2_IMPORT_PATH en inicializar.lua a tu ruta real..."
    sed -i -E "s#QML2_IMPORT_PATH=[^ ]+#QML2_IMPORT_PATH=${build_path}#" "$target"
    ok "QML2_IMPORT_PATH -> $build_path"
}

# ---------------------------------------------------------------------------
# Servicios del sistema
# ---------------------------------------------------------------------------
setup_services() {
    info "Habilitando servicios..."
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
        || warn "No se pudieron habilitar los servicios de pipewire (¿ya están activos?)"
    sudo systemctl enable --now NetworkManager \
        || warn "No se pudo habilitar NetworkManager"
    sudo systemctl enable --now bluetooth \
        || warn "No se pudo habilitar bluetooth"
    ok "Servicios configurados"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    check_arch
    check_not_root

    echo "=================================================="
    echo " jozet-dotfiles — instalador"
    echo " Repo:    $REPO_DIR"
    echo " Backups: $BACKUP_DIR (solo si hace falta)"
    echo "=================================================="

    confirm "¿Continuar con la instalación?" || die "Cancelado por el usuario."

    ensure_yay
    install_packages
    link_configs
    build_backend
    fix_import_path
    setup_services

    echo
    ok "¡Listo! Cierra sesión y entra a Hyprland desde tu display manager."
    warn "Si algo se veía distinto antes, tus configs viejas quedaron en: $BACKUP_DIR"
}

main "$@"
