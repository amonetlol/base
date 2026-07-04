#!/usr/bin/env bash
# Aplica rofi-wallpaper.sh (awww/swww/swaybg) em todos os temas custom

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/vendor/custom/rofi-wallpaper.sh"
CUSTOM_CACHE="${CUSTOM_CACHE:-$HOME/.cache/base-custom-repo}"

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }

THEMES=(
  theme-bamboo
  theme-edge
  theme-everforest
  theme-glass
  theme-gruvbox
  theme-orange
  theme-prateado
  theme-sonokai
)

[[ -f "$SRC" ]] || { echo "Origem não encontrada: $SRC" >&2; exit 1; }

patch_dir() {
  local base="$1"
  [[ -d "$base" ]] || return 0
  cp "$SRC" "$base/wallpaper.sh"
  chmod +x "$base/wallpaper.sh"
  ok "wallpaper.sh → $base"
}

for theme in "${THEMES[@]}"; do
  patch_dir "$CUSTOM_CACHE/custom/$theme/rofi"
  patch_dir "$HOME/.config/custom/$theme/rofi"
done

ok "Rofi wallpaper atualizado em ${#THEMES[@]} temas (awww, swww, swaybg)"
