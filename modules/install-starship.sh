#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/dot.sh
source "$SCRIPT_DIR/lib/dot.sh"

if ! command -v starship >/dev/null 2>&1; then
  dot_log "Instalando starship em ~/.local/bin..."
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  dot_ok "starship instalado em $HOME/.local/bin/starship"
else
  dot_ok "starship já instalado: $(command -v starship)"
fi

dot_ensure_repo
src="$DOT_CACHE/dotfiles/starship/.config"
if [[ ! -d "$src" ]]; then
  dot_fail "Origem não encontrada: $src"
fi

mkdir -p "$HOME/.config"
for file in "$src"/*; do
  [[ -f "$file" ]] || continue
  dest="$HOME/.config/$(basename "$file")"
  dot_backup_path "$dest"
  cp -a "$file" "$dest"
  dot_ok "Copiado: $dest"
done
