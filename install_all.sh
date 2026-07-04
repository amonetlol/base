#!/usr/bin/env bash
# Instalador modular — executa scripts .sh da pasta modules/

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$ROOT/modules"

if [[ -t 1 ]]; then
  RED="\033[0;31m"
  GREEN="\033[0;32m"
  YELLOW="\033[1;33m"
  BLUE="\033[0;34m"
  BOLD="\033[1m"
  RESET="\033[0m"
else
  RED="" GREEN="" YELLOW="" BLUE="" BOLD="" RESET=""
fi

log() { echo -e "${BLUE}[INFO]${RESET} $*"; }
ok() { echo -e "${GREEN}[OK]${RESET} $*"; }
warn() { echo -e "${YELLOW}[AVISO]${RESET} $*"; }
fail() { echo -e "${RED}[ERRO]${RESET} $*" >&2; }

declare -a MODULE_SCRIPTS=()
declare -a MODULE_ORDER=(
  install-vmware.sh
  setup-nvim.sh
  install-hypr-temas.sh
  install-fonts.sh
  chaotic-aur.sh
  install-sddm-theme.sh
  hide-shortcuts.sh
  install-kitty.sh
  install-alacritty.sh
  install-btop.sh
  install-fastfetch.sh
  install-starship.sh
  install-bin.sh
  install-bash.sh
  install-rice.sh
  install-wallpapers.sh
)
declare -A MODULE_LABELS=(
  [install-vmware.sh]="VMware (open-vm-tools)"
  [setup-nvim.sh]="Neovim"
  [install-hypr-temas.sh]="Hypr + temas (custom)"
  [install-fonts.sh]="Fontes"
  [chaotic-aur.sh]="Chaotic-AUR"
  [install-sddm-theme.sh]="SDDM Theme"
  [hide-shortcuts.sh]="Hide Shortcuts"
  [install-kitty.sh]="Kitty configs"
  [install-alacritty.sh]="Alacritty configs"
  [install-btop.sh]="Btop configs"
  [install-fastfetch.sh]="Fastfetch configs"
  [install-starship.sh]="Starship configs"
  [install-bin.sh]="Bin configs"
  [install-bash.sh]="Bash configs"
  [install-rice.sh]="Rice configs"
  [install-wallpapers.sh]="Wallpapers"
)

load_modules() {
  MODULE_SCRIPTS=()
  local name script path

  for name in "${MODULE_ORDER[@]}"; do
    path="$MODULES_DIR/$name"
    [[ -f "$path" ]] && MODULE_SCRIPTS+=("$path")
  done

  while IFS= read -r script; do
    name="$(basename "$script")"
    case "$name" in
      install-*.sh|setup-*.sh|hide-*.sh|chaotic-aur.sh) ;;
      *) continue ;;
    esac
    for path in "${MODULE_SCRIPTS[@]}"; do
      [[ "$(basename "$path")" == "$name" ]] && continue 2
    done
    MODULE_SCRIPTS+=("$script")
  done < <(find "$MODULES_DIR" -maxdepth 1 -type f -name '*.sh' | sort)
}

module_label() {
  local base
  base="$(basename "$1")"
  echo "${MODULE_LABELS[$base]:-$base}"
}

show_menu() {
  local i script
  echo
  echo -e "${BOLD}${BLUE}========================================${RESET}"
  echo -e "${BOLD} Instalador Modular — base${RESET}"
  echo -e "${BOLD}${BLUE}========================================${RESET}"
  echo
  for i in "${!MODULE_SCRIPTS[@]}"; do
    script="${MODULE_SCRIPTS[$i]}"
    printf " %2d) %s\n" "$((i + 1))" "$(module_label "$script")"
  done
  echo
  echo "  0) Sair"
  echo
  echo "Selecione: número (1), vários (1,3,5), range (1-3) ou all"
  echo
}

parse_selection() {
  local input="$1"
  local -n _result=$2
  local max="${#MODULE_SCRIPTS[@]}"
  _result=()

  input="$(echo "$input" | tr -d ' ' | tr '[:upper:]' '[:lower:]')"

  if [[ -z "$input" ]]; then
    return 1
  fi

  if [[ "$input" == "all" || "$input" == "todos" || "$input" == "a" ]]; then
    local i
    for ((i = 1; i <= max; i++)); do
      _result+=("$i")
    done
    return 0
  fi

  local part start end i
  IFS=',' read -ra parts <<<"$input"
  for part in "${parts[@]}"; do
    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      start="${BASH_REMATCH[1]}"
      end="${BASH_REMATCH[2]}"
      if ((start > end)); then
        local tmp="$start"
        start="$end"
        end="$tmp"
      fi
      for ((i = start; i <= end; i++)); do
        if ((i >= 1 && i <= max)); then
          _result+=("$i")
        else
          return 1
        fi
      done
    elif [[ "$part" =~ ^[0-9]+$ ]]; then
      if ((part >= 1 && part <= max)); then
        _result+=("$part")
      else
        return 1
      fi
    else
      return 1
    fi
  done

  if [[ "${#_result[@]}" -eq 0 ]]; then
    return 1
  fi

  local -A seen=()
  local unique=()
  for i in "${_result[@]}"; do
    if [[ -z "${seen[$i]:-}" ]]; then
      seen[$i]=1
      unique+=("$i")
    fi
  done
  _result=("${unique[@]}")
  return 0
}

run_module() {
  local index="$1"
  local script="${MODULE_SCRIPTS[$((index - 1))]}"
  local label
  label="$(module_label "$script")"

  echo
  echo -e "${BOLD}>>> Instalando: $label${RESET}"
  echo -e "${BLUE}Script:${RESET} $script"
  echo

  if [[ ! -x "$script" ]]; then
    chmod +x "$script"
  fi

  set +e
  bash "$script"
  local rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    echo -e "${GREEN}[SUCESSO]${RESET} $label"
    return 0
  fi

  echo -e "${RED}[FALHOU]${RESET} $label (código $rc)"
  return 1
}

process_selection() {
  local choices=("$@")
  local id success=0 failed=0

  echo
  echo -e "${BOLD}Resumo da operação${RESET}"
  echo "----------------------------------------"

  for id in "${choices[@]}"; do
    if run_module "$id"; then
      ((success++)) || true
    else
      ((failed++)) || true
    fi
  done

  echo "----------------------------------------"
  echo -e "Concluído: ${GREEN}$success sucesso${RESET}, ${RED}$failed falha(s)${RESET}"
  echo
}

main() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    warn "Este script foi feito para Linux."
  fi

  if [[ "${EUID:-0}" -eq 0 ]]; then
    fail "Não execute como root. Use seu usuário normal com sudo."
    exit 1
  fi

  load_modules

  if [[ "${#MODULE_SCRIPTS[@]}" -eq 0 ]]; then
    fail "Nenhum módulo .sh encontrado em $MODULES_DIR"
    exit 1
  fi

  local input choices=()

  while true; do
    show_menu
    read -r -p "Escolha: " input

    input="$(echo "$input" | tr -d ' ' | tr '[:upper:]' '[:lower:]')"

    if [[ "$input" == "0" || "$input" == "sair" || "$input" == "q" || "$input" == "exit" ]]; then
      ok "Até logo!"
      exit 0
    fi

    if ! parse_selection "$input" choices; then
      warn "Seleção inválida. Use 1-${#MODULE_SCRIPTS[@]}, 1,3,5, 1-3 ou all."
      continue
    fi

    process_selection "${choices[@]}"

    read -r -p "Pressione Enter para voltar ao menu..."
  done
}

main "$@"
