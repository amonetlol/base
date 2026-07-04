#!/usr/bin/env bash
# Instala dependências unzip/tar/xz/gtk3 em arch, fedora ou ubuntu

install_rice_dependencies() {
  # shellcheck source=lib/distro.sh
  source "$1/lib/distro.sh"

  local base missing=()
  base="$(detect_distro_base)"

  case "$base" in
    arch)
      # shellcheck source=lib/common.sh
      source "$1/lib/common.sh"
      ensure_sudo
      install_packages_smart unzip tar xz gtk3
      ;;
    fedora)
      command -v unzip >/dev/null 2>&1 || missing+=(unzip)
      command -v tar >/dev/null 2>&1 || missing+=(tar)
      command -v xz >/dev/null 2>&1 || missing+=(xz)
      rpm -q gtk3 >/dev/null 2>&1 || missing+=(gtk3)
      if [[ ${#missing[@]} -gt 0 ]]; then
        sudo dnf install -y "${missing[@]}"
      fi
      ;;
    ubuntu)
      command -v unzip >/dev/null 2>&1 || missing+=(unzip)
      command -v tar >/dev/null 2>&1 || missing+=(tar)
      command -v xz >/dev/null 2>&1 || missing+=(xz-utils)
      dpkg -l libgtk-3-0 >/dev/null 2>&1 || missing+=(libgtk-3-0)
      if [[ ${#missing[@]} -gt 0 ]]; then
        sudo apt-get update -qq
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y "${missing[@]}"
      fi
      ;;
    *)
      echo "Base não suportada para Rice: $base" >&2
      return 1
      ;;
  esac
}
