#!/usr/bin/env bash

is_arch_based() {
  [[ -f /etc/arch-release ]] && return 0
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}:${ID_LIKE:-}" in
      arch*|*:arch*|cachyos*|manjaro*|endeavouros*|garuda*)
        return 0
        ;;
    esac
  fi
  return 1
}

is_fedora_based() {
  [[ -f /etc/fedora-release ]] && return 0
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}:${ID_LIKE:-}" in
      fedora*|*:fedora*|rhel*|centos*|rocky*|alma*)
        return 0
        ;;
    esac
  fi
  return 1
}

is_ubuntu_based() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}:${ID_LIKE:-}" in
      ubuntu*|debian*|pop*|linuxmint*|zorin*|elementary*|*:ubuntu*|*:debian*)
        return 0
        ;;
    esac
  fi
  [[ -f /etc/debian_version ]] && return 0
  return 1
}

detect_distro_base() {
  if is_arch_based; then
    echo "arch"
  elif is_fedora_based; then
    echo "fedora"
  elif is_ubuntu_based; then
    echo "ubuntu"
  else
    echo "unknown"
  fi
}

is_supported_base() {
  case "$(detect_distro_base)" in
    arch|fedora|ubuntu) return 0 ;;
    *) return 1 ;;
  esac
}
