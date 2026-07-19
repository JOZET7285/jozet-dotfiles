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

PACMAN_PKGS=(
    hyprland qt6-base qt6-declarative quickshell awww capitaine-cursors
    cmake base-devel git
    networkmanager network-manager-applet
    pipewire pipewire-pulse pipewire-alsa wireplumber
    playerctl brightnessctl power-profiles-daemon
    bluez bluez-utils
    kitty neovim zsh
    ttf-jetbrains-mono-nerd ttf-firacode-nerd
    starship fastfetch
    sh-autosuggestions
    zsh-syntax-highlighting
)

declare -A LINK_MAP=(
    [".config/hypr"]="$HOME/.config/hypr"
    [".config/quickshell"]="$HOME/.config/quickshell"
    [".config/kitty"]="$HOME/.config/kitty"
    [".config/fastfetch"]="$HOME/.config/fastfetch"
    [".config/nvim"]="$HOME/.config/nvim"
    [".config/gtk-3.0"]="$HOME/.config/gtk-3.0"
    [".config/gtk-4.0"]="$HOME/.config/gtk-4.0"
    [".config/starship.toml"]="$HOME/.config/starship.toml"
    ["home/.zshrc"]="$HOME/.zshrc"
)

# ---------------------------------------------------------------------------
# Output U.
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
# Checks prev.
# ---------------------------------------------------------------------------
check_arch() {
    command -v pacman >/dev/null 2>&1 || die "This rice is only for Arch Linux or distributions based on it."
}

check_not_root() {
    if [[ "$EUID" -eq 0 ]]; then 
        die "Do not run this script as the root user. Use your normal user account."
    fi
}

ensure_yay() {
    if command -v yay >/dev/null 2>&1; then
        ok "yay ya está instalado"
        return
    fi
    info "yay is not installed; it will be installed automatically."
    sudo pacman -S --needed --noconfirm base-devel git
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "yay installed"
}

# ---------------------------------------------------------------------------
# Packages installation
# ---------------------------------------------------------------------------
install_packages() {
    info "Installing official packages..."
    yay -S --needed --noconfirm "${PACMAN_PKGS[@]}" \
        || die "falla la instalacion de paquetes oficiales"
    ok "Official packages installed."

    info "installing packages from the AUR..."
    yay -S --needed --noconfirm "${AUR_PKGS[@]}" \
        || die "AUR package installation failed."
    ok "AUR packages installed."
}

# ---------------------------------------------------------------------------
# Symlinks with backup
# ---------------------------------------------------------------------------
link_configs() {
    info "Linking configurations..."
    mkdir -p "$HOME/.config"

    for src_rel in "${!LINK_MAP[@]}"; do
        local src="$REPO_DIR/$src_rel"
        local dst="${LINK_MAP[$src_rel]}"

        [[ -e "$src" ]] || { warn "$src does not exist, skipping..."; continue; }

        if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
            ok "$dst points to $src"
            continue
        fi

        if [[ -e "$dst" || -L "$dst" ]]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$src_rel")"
            mv "$dst" "$BACKUP_DIR/$src_rel"
            warn "Backup: $dst -> $BACKUP_DIR/$src_rel"
        fi

        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
        ok "Linking $dst -> $src"
    done
}

# ---------------------------------------------------------------------------
# Backend Qt (JozetPlugin)
# ---------------------------------------------------------------------------
build_backend() {
    info "Compiling plugin of Qt (backend)..."
    cmake -S "$REPO_DIR/backend" -B "$REPO_DIR/backend/build" -DCMAKE_BUILD_TYPE=Release \
        || die "CMake failed to configure the backend."
    cmake --build "$REPO_DIR/backend/build" -j"$(nproc)" \
        || die "The backend compilation failed."
    ok "Backend compiled in $REPO_DIR/backend/build"
}

fix_import_path() {
    local target="$HOME/.config/hypr/lua/inicializar.lua"
    local build_path="$REPO_DIR/backend/build"

    [[ -f "$target" ]] || { warn "$target not found, skipping route fix..."; return; }

    if grep -q "QML2_IMPORT_PATH=$build_path" "$target"; then
        ok "The initializer already points to the correct dir."
        return
    fi

    info "Adjusting QML2_IMPORT_PATH in inicializar.lua..."
    sed -i -E "s#QML2_IMPORT_PATH=[^ ]+#QML2_IMPORT_PATH=${build_path}#" "$target"
    ok "QML2_IMPORT_PATH -> $build_path"
}

# ---------------------------------------------------------------------------
# System Services
# ---------------------------------------------------------------------------
setup_services() {
    info "Enabling services..."
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
        || warn "The PipeWire services could not be enabled. (Are they already active?)"
    sudo systemctl enable --now NetworkManager \
        || warn "NetworkManager could not be enabled."
    sudo systemctl enable --now bluetooth \
        || warn "Bluetooth could not be enabled."
    ok "configured services"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    check_arch
    check_not_root

    echo "=================================================="
    echo " jozet-dotfiles — installer"
    echo " Repo:    $REPO_DIR"
    echo " Backups: $BACKUP_DIR "
    echo "=================================================="

    confirm "Continue with the installation?" || die "cancelled by the user."

    ensure_yay
    install_packages
    link_configs
    build_backend
    fix_import_path
    setup_services

    echo
    ok "Your rice is ready! Log out and enter Hyprland from your display manager to enjoy it.."
    warn "Your settings were not deleted; they were saved in: $BACKUP_DIR"
}

main "$@"
