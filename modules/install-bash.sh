#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/dot.sh
source "$SCRIPT_DIR/lib/dot.sh"
dot_install_home_files "dotfiles/bash" \
  ".aliases" \
  ".aliases-arch" \
  ".aliases-debian" \
  ".aliases-fedora" \
  ".aliases-nixos" \
  ".aliases-opensuse" \
  ".aliases-solus" \
  ".bash_profile" \
  ".functions"

cp "$REPO_ROOT/vendor/bash/.bashrc" "$HOME/.bashrc"
dot_ok "Copiado: $HOME/.bashrc (vendor — starship nord ativo)"

dot_install_bin
