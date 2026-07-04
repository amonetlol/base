#!/usr/bin/env bash
# Helpers para instalar dotfiles do repositório amonetlol/dot

DOT_REPO="${DOT_REPO:-https://github.com/amonetlol/dot.git}"
DOT_CACHE="${DOT_CACHE:-$HOME/.cache/base-dot-repo}"

dot_log() { printf "[*] %s\n" "$1"; }
dot_ok() { printf "[OK] %s\n" "$1"; }
dot_warn() { printf "[AVISO] %s\n" "$1"; }
dot_fail() { printf "[ERRO] %s\n" "$1" >&2; exit 1; }

dot_backup_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    local backup="${path}.bak-$(date +%Y%m%d-%H%M%S)"
    dot_log "Backup: $path -> $backup"
    mv "$path" "$backup"
  fi
}

dot_copy_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src/" "$dest/"
  else
    cp -a "$src/." "$dest/"
  fi
}

dot_ensure_repo() {
  if ! command -v git >/dev/null 2>&1; then
    dot_fail "git não encontrado."
  fi

  if [[ -d "$DOT_CACHE/.git" ]]; then
    dot_log "Atualizando cache dot: $DOT_CACHE"
    git -C "$DOT_CACHE" pull --ff-only 2>/dev/null || dot_warn "git pull falhou — usando cache local"
    return 0
  fi

  mkdir -p "$(dirname "$DOT_CACHE")"
  dot_log "Clonando $DOT_REPO -> $DOT_CACHE"
  git clone --depth 1 "$DOT_REPO" "$DOT_CACHE"
}

# Instala um subdiretório do dot repo no destino do usuário.
# Uso: dot_install_config "dotfiles/kitty/.config/kitty" "$HOME/.config/kitty"
dot_install_config() {
  local rel_src="$1"
  local dest="$2"
  local src="$DOT_CACHE/$rel_src"

  dot_ensure_repo

  if [[ ! -d "$src" ]]; then
    dot_fail "Origem não encontrada: $src"
  fi

  dot_backup_path "$dest"
  mkdir -p "$dest"
  dot_copy_tree "$src" "$dest"
  dot_ok "Instalado: $dest ($(find "$dest" -type f | wc -l) ficheiros)"
}

dot_install_bin() {
  local src="$DOT_CACHE/dotfiles/bin/.bin"
  local dest="$HOME/.bin"

  dot_ensure_repo

  if [[ ! -d "$src" ]]; then
    dot_fail "Origem não encontrada: $src"
  fi

  dot_backup_path "$dest"
  mkdir -p "$(dirname "$dest")"
  dot_copy_tree "$src" "$dest"
  find "$dest" -type f -exec chmod +x {} + 2>/dev/null || true
  dot_ok "Instalado: $dest ($(find "$dest" -maxdepth 1 -type f | wc -l) scripts)"
}

# Copia arquivos soltos de um diretório para $HOME
dot_install_home_files() {
  local rel_src="$1"
  shift
  local files=("$@")
  local src_dir="$DOT_CACHE/$rel_src"
  local file src dest

  dot_ensure_repo

  if [[ ! -d "$src_dir" ]]; then
    dot_fail "Origem não encontrada: $src_dir"
  fi

  for file in "${files[@]}"; do
    src="$src_dir/$file"
    dest="$HOME/$file"
    if [[ ! -f "$src" ]]; then
      dot_fail "Arquivo não encontrado: $src"
    fi
    dot_backup_path "$dest"
    cp -a "$src" "$dest"
    dot_ok "Copiado: $dest"
  done
}
