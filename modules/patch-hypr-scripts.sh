#!/usr/bin/env bash
# Copia scripts vendored para ~/.config/hypr e garante exec-once no hyprland.conf

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_HYPR="$REPO_ROOT/vendor/hypr"
CUSTOM_CACHE="${CUSTOM_CACHE:-$HOME/.cache/base-custom-repo}"
GTK_LINE='exec-once = ~/.config/hypr/scripts/gtkthemes'

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }

deploy_scripts() {
  local dest="$1"
  local src="$VENDOR_HYPR/scripts"

  [[ -d "$src" ]] || return 0
  mkdir -p "$dest"
  cp -a "$src/." "$dest/"
  find "$dest" -type f -exec chmod +x {} +
  ok "scripts → $dest"
}

ensure_gtkthemes_exec() {
  local conf="$1"
  [[ -f "$conf" ]] || return 0

  if grep -qF 'scripts/gtkthemes' "$conf"; then
    ok "exec-once gtkthemes já em $conf"
    return 0
  fi

  if grep -q '^### AUTOSTART ###' "$conf"; then
    sed -i "/^### AUTOSTART ###/a $GTK_LINE" "$conf"
  else
    printf '\n%s\n%s\n' '#################' '### AUTOSTART ###' >>"$conf"
    printf '%s\n' "$GTK_LINE" >>"$conf"
  fi
  ok "exec-once gtkthemes adicionado em $conf"
}

deploy_scripts "$HOME/.config/hypr/scripts"
deploy_scripts "$CUSTOM_CACHE/hypr/scripts"

ensure_gtkthemes_exec "$HOME/.config/hypr/hyprland.conf"
ensure_gtkthemes_exec "$CUSTOM_CACHE/hypr/hyprland.conf"

ok "Hypr scripts e gtkthemes configurados"
