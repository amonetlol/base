#!/usr/bin/env bash
# open-vm-tools when running inside VMware (Arch / Fedora / Ubuntu)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sudo.sh
source "$SCRIPT_DIR/lib/sudo.sh"
# shellcheck source=lib/distro.sh
source "$SCRIPT_DIR/lib/distro.sh"

warn() { printf "[AVISO] %s\n" "$1"; }

is_vmware() {
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    [[ "$(systemd-detect-virt)" == "vmware" ]] && return 0
  fi
  grep -qi vmware /sys/class/dmi/id/product_name 2>/dev/null && return 0
  grep -qi vmware /sys/class/dmi/id/sys_vendor 2>/dev/null && return 0
  return 1
}

if ! is_vmware; then
  echo "Não é VMware — open-vm-tools ignorado."
  exit 0
fi

BASE="$(detect_distro_base)"
echo "VMware detectado — instalando open-vm-tools (base: $BASE)..."

case "$BASE" in
  arch)
    if ! sudo pacman -S --needed --noconfirm open-vm-tools gtkmm3 fuse2 fuse3; then
      warn "open-vm-tools falhou (mirrors?) — continuando sem vmtoolsd"
      exit 0
    fi
    ;;
  fedora)
    if ! sudo dnf install -y open-vm-tools open-vm-tools-desktop; then
      warn "open-vm-tools falhou — continuando sem vmtoolsd"
      exit 0
    fi
    ;;
  ubuntu)
    if ! sudo apt-get update -qq; then
      warn "apt-get update falhou"
      exit 0
    fi
    if ! sudo apt-get install -y open-vm-tools open-vm-tools-desktop; then
      warn "open-vm-tools falhou — continuando sem vmtoolsd"
      exit 0
    fi
    ;;
  *)
    echo "Base não suportada ($BASE) — VMware ignorado."
    exit 0
    ;;
esac

sudo systemctl enable --now vmtoolsd 2>/dev/null || \
  sudo systemctl enable --now open-vm-tools 2>/dev/null || \
  warn "serviço vmtoolsd não ativado"
echo "open-vm-tools configurado."
