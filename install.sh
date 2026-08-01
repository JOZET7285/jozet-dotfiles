#!/usr/bin/env bash
#
# install.sh — jozet-dotfiles installer
#
# Requires Arch Linux (or a derivative) with yay available or installable.
# Usage:
#   ./install.sh            normal installation (with confirmations)
#   ./install.sh --yes      skip all prompts, assume "yes" to everything
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
    hyprland qt6-base qt6-declarative awww capitaine-cursors
    cmake base-devel git qt6-5compat jq
    networkmanager network-manager-applet
    pipewire pipewire-pulse pipewire-alsa wireplumber
    playerctl brightnessctl power-profiles-daemon
    bluez bluez-utils
    kitty neovim zsh
    ttf-jetbrains-mono-nerd ttf-firacode-nerd
    starship fastfetch
    zsh-autosuggestions
    zsh-syntax-highlighting
)

AUR_PKGS=(
    matugen-bin
    quickshell-git
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
    [".config/matugen"]="$HOME/.config/matugen"
    ["home/.zshrc"]="$HOME/.zshrc"
)

# ---------------------------------------------------------------------------
# Output
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
    read -rp "$(echo -e "${c_warn}?${c_off} ${prompt} [y/N] ")" reply
    [[ "$reply" =~ ^[yY]$ ]]
}

# ---------------------------------------------------------------------------
# Pre-checks
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
        ok "yay is already installed"
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
# Conflicting packages
# ---------------------------------------------------------------------------
ensure_no_quickshell_conflict() {
    if pacman -Qi quickshell >/dev/null 2>&1; then
        warn "The stable 'quickshell' package is installed and conflicts with quickshell-git."
        if confirm "Remove the stable quickshell package to install quickshell-git?"; then
            sudo pacman -R --noconfirm quickshell
            ok "Stable quickshell removed."
        else
            die "Cannot continue with quickshell and quickshell-git in conflict."
        fi
    fi
}

# ---------------------------------------------------------------------------
# Packages installation
# ---------------------------------------------------------------------------
install_packages() {
    info "Installing official packages..."
    yay -S --needed --noconfirm "${PACMAN_PKGS[@]}" \
        || die "Failed to install official packages."
    ok "Official packages installed."

    ensure_no_quickshell_conflict

    if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
        info "Installing packages from the AUR..."
        yay -S --needed --noconfirm "${AUR_PKGS[@]}" \
            || die "AUR package installation failed."
        ok "AUR packages installed."
    fi
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
# Qt backend (JozetPlugin)
# ---------------------------------------------------------------------------
build_backend() {
    info "Compiling the Qt plugin (backend)..."
    cmake -S "$REPO_DIR/backend" -B "$REPO_DIR/backend/build" -DCMAKE_BUILD_TYPE=Release \
        || die "CMake failed to configure the backend."
    cmake --build "$REPO_DIR/backend/build" -j"$(nproc)" \
        || die "The backend compilation failed."
    ok "Backend compiled in $REPO_DIR/backend/build"
}

fix_import_path() {
    local target="$HOME/.config/hypr/lua/inicializar.lua"
    local build_path="$REPO_DIR/backend/build"

    [[ -f "$target" ]] || { warn "$target not found, skipping path fix..."; return; }

    if grep -q "QML2_IMPORT_PATH=$build_path" "$target"; then
        ok "The initializer already points to the correct directory."
        return
    fi

    info "Adjusting QML2_IMPORT_PATH in inicializar.lua..."
    sed -i -E "s#QML2_IMPORT_PATH=[^ ]+#QML2_IMPORT_PATH=${build_path}#" "$target"
    ok "QML2_IMPORT_PATH -> $build_path"
}

# ---------------------------------------------------------------------------
# System services
# ---------------------------------------------------------------------------
setup_services() {
    info "Enabling services..."
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
        || warn "The PipeWire services could not be enabled. (Are they already active?)"
    sudo systemctl enable --now NetworkManager \
        || warn "NetworkManager could not be enabled."
    sudo systemctl enable --now bluetooth \
        || warn "Bluetooth could not be enabled."
    ok "Services configured."
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

    confirm "Continue with the installation?" || die "Cancelled by the user."

    ensure_yay
    install_packages
    link_configs
    build_backend
    fix_import_path
    setup_services

    echo
    ok "Your rice is ready! Log out and enter Hyprland from your display manager to enjoy it."
    warn "Your previous settings were not deleted; they were saved in: $BACKUP_DIR"
}

main "$@"
