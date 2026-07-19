#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$REPO_DIR/backend/build"

c_info="\033[1;34m"; c_ok="\033[1;32m"; c_warn="\033[1;33m"; c_err="\033[1;31m"; c_off="\033[0m"
info()  { echo -e "${c_info}==>${c_off} $*"; }
ok()    { echo -e "${c_ok}  ✓${c_off} $*"; }
warn()  { echo -e "${c_warn}  !${c_off} $*"; }
err()   { echo -e "${c_err}  ✗${c_off} $*" >&2; }
die()   { err "$*"; exit 1; }

cd "$REPO_DIR" || die "Could not enter $REPO_DIR"

[[ -d .git ]] || die "$REPO_DIR is not a git repository"

if [[ -d "$BUILD_DIR" ]] && git ls-files --error-unmatch "$BUILD_DIR" &>/dev/null; then
    warn "backend/build/ is still tracked in this repo, discarding local changes there..."
    git checkout -- "$BUILD_DIR" 2>/dev/null || true
    git clean -fd "$BUILD_DIR" 2>/dev/null || true
fi

STASHED=false
if ! git diff --quiet || ! git diff --cached --quiet; then
    info "Saving your local changes to a temporary stash..."
    git stash push -u -m "update.sh auto-stash $(date +%Y%m%d-%H%M%S)" \
        || die "Could not save your local changes, please check 'git status' manually"
    STASHED=true
fi

info "Updating from origin..."
if ! git pull; then
    err "git pull failed"
    if $STASHED; then
        warn "Your changes are still in the stash, recover them with: git stash pop"
    fi
    die "Resolve the conflict manually and run the script again"
fi
ok "Repository updated"

if $STASHED; then
    info "Restoring your local changes..."
    if ! git stash pop; then
        err "Conflict while restoring stash — your changes are still there"
        die "Resolve it manually using 'git status' / 'git stash show -p' and then 'git stash drop'"
    fi
    ok "Local changes restored"
fi

info "Recompiling Qt plugin (backend)..."
cmake -S "$REPO_DIR/backend" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release \
    || die "cmake failed to configure the backend"
cmake --build "$BUILD_DIR" -j"$(nproc)" \
    || die "Backend compilation failed"
ok "Backend recompiled in $BUILD_DIR"

target="$HOME/.config/hypr/lua/inicializar.lua"
if [[ -f "$target" ]]; then
    if grep -q "QML2_IMPORT_PATH=$BUILD_DIR" "$target"; then
        ok "inicializar.lua already points to the correct path"
    else
        info "Adjusting QML2_IMPORT_PATH in inicializar.lua to your actual path..."
        sed -i -E "s#QML2_IMPORT_PATH=[^ ]+#QML2_IMPORT_PATH=${BUILD_DIR}#" "$target"
        ok "QML2_IMPORT_PATH -> $BUILD_DIR"
    fi
else
    warn "Could not find $target, skipping path adjustment"
fi

echo
ok "Done! Reload Hyprland (or log out) to apply changes."
