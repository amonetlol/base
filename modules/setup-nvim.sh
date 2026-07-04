#!/usr/bin/env bash
# Neovim: clone direto de amonetlol/nvim → ~/.config/nvim (sem matugen / theme engine)

set -euo pipefail

NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
THEMES_NVIM="${XDG_CONFIG_HOME:-$HOME/.config}/themes/nvim"
NVIM_REPO="https://github.com/amonetlol/nvim.git"

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }
warn() { printf "[AVISO] %s\n" "$1"; }

# Legado: symlink ~/.config/nvim → ~/.config/themes/nvim
if [[ -L "$NVIM_DIR" ]]; then
  log "Removendo symlink legado $NVIM_DIR"
  rm -f "$NVIM_DIR"
fi
if [[ -d "$THEMES_NVIM" ]]; then
  log "Removendo $THEMES_NVIM (legado theme engine)"
  rm -rf "$THEMES_NVIM"
fi

if [[ -e "$NVIM_DIR" && ! -d "$NVIM_DIR/.git" ]]; then
  warn "$NVIM_DIR existe mas não é um clone git — movendo para ${NVIM_DIR}.bak"
  mv "$NVIM_DIR" "${NVIM_DIR}.bak"
fi

if [[ -d "$NVIM_DIR/.git" ]]; then
  log "Atualizando $NVIM_DIR"
  git -C "$NVIM_DIR" pull --ff-only 2>/dev/null || warn "git pull falhou — verifique manualmente"
else
  log "Clonando $NVIM_REPO → $NVIM_DIR"
  rm -rf "$NVIM_DIR"
  git clone --depth=1 "$NVIM_REPO" "$NVIM_DIR"
fi

ok "nvim em $NVIM_DIR — rode :Lazy sync na primeira abertura"
