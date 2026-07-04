#!/usr/bin/env bash
# Chaotic-AUR setup (vendored, frozen flow)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sudo.sh
source "$SCRIPT_DIR/lib/sudo.sh"
# shellcheck source=lib/distro.sh
source "$SCRIPT_DIR/lib/distro.sh"

if ! is_arch_based; then
  echo "Não é base Arch — Chaotic-AUR ignorado."
  exit 0
fi

echo "=== Adicionando Chaotic-AUR ==="

echo "→ Recebendo chave GPG..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

echo "→ Instalando chaotic-keyring e chaotic-mirrorlist..."
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo "→ Configurando /etc/pacman.conf..."
if ! grep -q '\[chaotic-aur\]' /etc/pacman.conf; then
  sudo_append_to_file /etc/pacman.conf <<'EOF'

[chaotic-aur]
SigLevel = Optional TrustedOnly
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  echo "Repositório Chaotic-AUR adicionado."
else
  echo "Chaotic-AUR já configurado."
fi

echo "→ Atualizando banco de dados..."
sudo pacman -Sy --noconfirm
echo "Chaotic-AUR pronto."
