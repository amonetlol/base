#!/usr/bin/env bash
# Fontes: pacman (Arch) + dot/Assets → ~/.fonts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS="$REPO_ROOT/Assets"
# shellcheck source=lib/distro.sh
source "$SCRIPT_DIR/lib/distro.sh"
# shellcheck source=lib/dot.sh
source "$SCRIPT_DIR/lib/dot.sh"

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }

install_pacman_fonts() {
  # shellcheck source=lib/sudo.sh
  source "$SCRIPT_DIR/lib/sudo.sh"
  sudo pacman -S --needed --noconfirm ttf-0xproto-nerd otf-geist-mono-nerd fontconfig
  ok "ttf-0xproto-nerd + otf-geist-mono-nerd"
}

install_assets_fonts() {
  local src="$ASSETS/.fonts"
  if [[ ! -d "$src" ]]; then
    log "Assets/.fonts ausente — rode: bash Assets/vendor-assets.sh --fonts"
    return 0
  fi
  mkdir -p "$HOME/.fonts"
  cp -a "$src/." "$HOME/.fonts/"
  ok "Assets → ~/.fonts ($(find "$HOME/.fonts" -type f | wc -l) ficheiros)"
}

install_dot_repo_fonts() {
  local src="$DOT_CACHE/dotfiles/fonts/.fonts"
  dot_ensure_repo
  if [[ ! -d "$src" ]]; then
    log "dotfiles/fonts/.fonts ausente no repositório dot"
    return 0
  fi
  mkdir -p "$HOME/.fonts"
  dot_copy_tree "$src" "$HOME/.fonts"
  ok "dot → ~/.fonts ($(find "$HOME/.fonts" -type f | wc -l) ficheiros)"
}

if is_arch_based; then
  install_pacman_fonts
  install_assets_fonts
elif is_fedora_based || is_ubuntu_based; then
  log "Base $(detect_distro_base) — pacman ignorado, usando fontes dot."
  install_dot_repo_fonts
  install_assets_fonts
else
  log "Base desconhecida — usando fontes dot."
  install_dot_repo_fonts
  install_assets_fonts
fi

fc-cache -fv "$HOME/.fonts" 2>/dev/null || fc-cache -fv
ok "fontconfig atualizado"
