#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/dot.sh
source "$SCRIPT_DIR/lib/dot.sh"
dot_install_config "dotfiles/btop/.config/btop/themes" "$HOME/.config/btop/themes"
