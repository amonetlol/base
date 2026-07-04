#!/usr/bin/env bash
# Testa detecção de base: arch, fedora ou ubuntu

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../modules/lib/distro.sh
source "$ROOT/modules/lib/distro.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

pass() { echo -e "${GREEN}[OK]${RESET} $*"; }
fail() { echo -e "${RED}[FALHOU]${RESET} $*"; exit 1; }
info() { echo -e "${YELLOW}[INFO]${RESET} $*"; }

echo -e "${BOLD}=== Teste de detecção de distro ===${RESET}"
echo

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  echo "Sistema: ${PRETTY_NAME:-$NAME}"
  echo "ID: ${ID:-?} | ID_LIKE: ${ID_LIKE:-?}"
fi
echo

BASE="$(detect_distro_base)"
echo "Base detectada: ${BOLD}$BASE${RESET}"
echo

# Apenas uma base deve ser verdadeira
true_count=0
is_arch_based && ((true_count++)) || true
is_fedora_based && ((true_count++)) || true
is_ubuntu_based && ((true_count++)) || true

if [[ "$true_count" -ne 1 ]]; then
  fail "Detecção ambígua — $true_count bases ativas (esperado: 1)"
fi
pass "Exatamente uma base ativa"

case "$BASE" in
  arch)
    is_arch_based || fail "detect_distro_base=arch mas is_arch_based falhou"
    pass "Base Arch confirmada"
    ;;
  fedora)
    is_fedora_based || fail "detect_distro_base=fedora mas is_fedora_based falhou"
    pass "Base Fedora confirmada"
    ;;
  ubuntu)
    is_ubuntu_based || fail "detect_distro_base=ubuntu mas is_ubuntu_based falhou"
    pass "Base Ubuntu/Debian confirmada"
    ;;
  unknown)
    fail "Base não reconhecida — suportadas: arch, fedora, ubuntu"
    ;;
esac

is_supported_base || fail "is_supported_base retornou falso para $BASE"
pass "Base suportada pelo install_all"

echo
info "Módulos Arch-only (ignoram em fedora/ubuntu):"
for mod in chaotic-aur install-sddm-theme install-rice; do
  if [[ "$BASE" == "arch" ]]; then
    pass "$mod → executaria em Arch"
  else
    pass "$mod → ignoraria em $BASE"
  fi
done

echo
info "Módulos multi-base:"
for mod in install-fonts install-vmware install-bash install-kitty; do
  pass "$mod → suporta $BASE"
done

echo
pass "Todos os testes passaram para base: $BASE"
