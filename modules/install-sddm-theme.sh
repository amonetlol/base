#!/usr/bin/env bash
# SDDM Catppuccin Frappe Blue — extrai tema corretamente.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sudo.sh
source "$SCRIPT_DIR/lib/sudo.sh"
# shellcheck source=lib/distro.sh
source "$SCRIPT_DIR/lib/distro.sh"

if ! is_arch_based; then
  echo "Não é base Arch — SDDM theme ignorado."
  exit 0
fi

REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS="$REPO_ROOT/Assets"
THEME_NAME="catppuccin-frappe-blue"
SDDM_THEMES="/usr/share/sddm/themes"
THEME_URL="https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip"

disable_other_dms() {
  for dm in lightdm gdm; do
    if systemctl is-enabled "$dm" &>/dev/null; then
      echo "Desativando $dm..."
      sudo systemctl disable --now "$dm" 2>/dev/null || sudo systemctl disable "$dm" || true
    fi
  done
}

install_theme() {
  local zip="$ASSETS/catppuccin-frappe-blue-sddm.zip"
  local tmp
  if [[ ! -f "$zip" ]]; then
    mkdir -p "$ASSETS"
    curl -fL "$THEME_URL" -o "$zip"
  fi
  tmp="$(mktemp -d)"
  unzip -oq "$zip" -d "$tmp"
  sudo rm -rf "$SDDM_THEMES/$THEME_NAME"
  # zip contém catppuccin-frappe-blue/ — mover para themes sem aninhar
  if [[ -d "$tmp/$THEME_NAME" ]]; then
    sudo mv "$tmp/$THEME_NAME" "$SDDM_THEMES/$THEME_NAME"
  else
    sudo mkdir -p "$SDDM_THEMES/$THEME_NAME"
    sudo mv "$tmp"/* "$SDDM_THEMES/$THEME_NAME/"
  fi
  rm -rf "$tmp"
  [[ -f "$SDDM_THEMES/$THEME_NAME/Main.qml" ]] || {
    echo "ERRO: Main.qml não encontrado em $SDDM_THEMES/$THEME_NAME"
    exit 1
  }
}

configure_sddm() {
  sudo_write_file /etc/sddm.conf.d/theme.conf <<EOF
[Theme]
Current=$THEME_NAME
EOF
  sudo chmod a+r /etc/sddm.conf.d/theme.conf
  # Garantir que não há Current conflitante no sddm.conf principal
  if grep -q '^Current=' /etc/sddm.conf 2>/dev/null; then
    sudo sed -i 's/^Current=.*/Current='"$THEME_NAME"'/' /etc/sddm.conf
  fi
}

sudo pacman -S --needed --noconfirm sddm qt6-svg qt6-declarative 2>/dev/null || \
  sudo pacman -S --needed --noconfirm sddm qt6-svg
disable_other_dms
install_theme
configure_sddm
sudo systemctl enable sddm
echo "SDDM tema $THEME_NAME instalado ($(ls "$SDDM_THEMES/$THEME_NAME/Main.qml" 2>/dev/null && echo OK))"
