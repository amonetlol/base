#!/usr/bin/env bash
# Baixa assets para Assets/ (temas, ícones, cursor, SDDM, fontes dot).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS="$ROOT/Assets"
DOT_ASSETS="https://github.com/amonetlol/dot/raw/main/Assets"
DOT_FONTS="https://github.com/amonetlol/dot/tree/main/dotfiles/fonts/.fonts"

mkdir -p "$ASSETS"

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }

for f in MacTahoe.tar.xz Qogir-cursors.tar.xz; do
  if [[ -f "$ASSETS/$f" ]]; then
    ok "$f (já existe)"
  else
    log "Baixando $f..."
    curl -fL "$DOT_ASSETS/$f" -o "$ASSETS/$f"
    ok "$f"
  fi
done

for gtk_zip in catppuccin-frappe-blue.zip catppuccin-frappe-blue-standard+default.zip; do
  if [[ -f "$ASSETS/$gtk_zip" ]]; then
    ok "$gtk_zip (já existe)"
    break
  fi
done
if [[ ! -f "$ASSETS/catppuccin-frappe-blue.zip" && ! -f "$ASSETS/catppuccin-frappe-blue-standard+default.zip" ]]; then
  if [[ -f "$ROOT/install/TO_CURSOR/catppuccin-frappe-blue.zip" ]]; then
    cp -f "$ROOT/install/TO_CURSOR/catppuccin-frappe-blue.zip" "$ASSETS/"
    ok "catppuccin-frappe-blue.zip (de install/TO_CURSOR)"
  else
    log "Baixando GTK catppuccin-frappe-blue..."
    curl -fL "$DOT_ASSETS/catppuccin-frappe-blue-standard+default.zip" \
      -o "$ASSETS/catppuccin-frappe-blue-standard+default.zip" || true
    ok "catppuccin GTK (se download OK)"
  fi
fi

if [[ -f "$ASSETS/catppuccin-frappe-blue-sddm.zip" ]]; then
  ok "catppuccin-frappe-blue-sddm.zip (já existe)"
else
  log "Baixando SDDM catppuccin..."
  curl -fL "https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip" \
    -o "$ASSETS/catppuccin-frappe-blue-sddm.zip"
  ok "SDDM zip"
fi

if [[ "${1:-}" == "--fonts" ]]; then
  log "Clonando fontes dot (pode demorar)..."
  tmp="$(mktemp -d)"
  git clone --depth=1 --filter=blob:none --sparse https://github.com/amonetlol/dot.git "$tmp/dot"
  git -C "$tmp/dot" sparse-checkout set dotfiles/fonts/.fonts
  rm -rf "$ASSETS/.fonts"
  cp -a "$tmp/dot/dotfiles/fonts/.fonts" "$ASSETS/.fonts"
  rm -rf "$tmp"
  ok "Assets/.fonts ($(find "$ASSETS/.fonts" -type f | wc -l) ficheiros)"
fi

ok "Assets prontos em $ASSETS"
