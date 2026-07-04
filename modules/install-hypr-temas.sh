#!/usr/bin/env bash
# Hypr + temas — clone amonetlol/custom e executa install.sh + install_hypr.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_REPO="${CUSTOM_REPO:-https://github.com/amonetlol/custom.git}"
CUSTOM_CACHE="${CUSTOM_CACHE:-$HOME/.cache/base-custom-repo}"

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }
fail() { printf "[ERRO] %s\n" "$1" >&2; exit 1; }

if ! command -v git >/dev/null 2>&1; then
  fail "git não encontrado."
fi

if [[ -d "$CUSTOM_CACHE/.git" ]]; then
  log "Atualizando cache custom: $CUSTOM_CACHE"
  git -C "$CUSTOM_CACHE" pull --ff-only 2>/dev/null || log "git pull falhou — usando cache local"
else
  mkdir -p "$(dirname "$CUSTOM_CACHE")"
  log "Clonando $CUSTOM_REPO -> $CUSTOM_CACHE"
  git clone --depth 1 "$CUSTOM_REPO" "$CUSTOM_CACHE"
fi

log "Executando install.sh"
bash "$CUSTOM_CACHE/install.sh"

log "Instalando scripts Hypr (gtkthemes)"
bash "$SCRIPT_DIR/patch-hypr-scripts.sh"

log "Executando install_hypr.sh"
bash "$CUSTOM_CACHE/install_hypr.sh"

log "Reaplicando scripts Hypr"
bash "$SCRIPT_DIR/patch-hypr-scripts.sh"

log "Aplicando rofi wallpaper (awww, swww, swaybg)"
bash "$SCRIPT_DIR/patch-rofi-wallpaper.sh"

[[ -d "$HOME/.config/hypr" ]] || fail "Hypr não instalado em ~/.config/hypr"
ok "Hypr + temas instalados em ~/.config/hypr e ~/.config/custom"
