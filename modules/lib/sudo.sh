#!/usr/bin/env bash
# Non-interactive sudo for remote/automated installs.

install_sudo_init() {
  if [[ -n "${INSTALL_SUDO_PASSWORD:-}" ]]; then
    printf '%s\n' "$INSTALL_SUDO_PASSWORD" | sudo -S -v
  elif [[ -n "${SUDO_ASKPASS:-}" && -x "${SUDO_ASKPASS}" ]]; then
    export DISPLAY="${DISPLAY:-:0}"
    sudo -A -v
  fi
}

# Pergunta no início da instalação (install_hyprland_full, apply-fixes).
# Se INSTALL_SUDO_PASSWORD já estiver exportado, mantém sem perguntar.
install_prompt_sudo_password() {
  if [[ -n "${INSTALL_SUDO_PASSWORD:-}" ]]; then
    printf "[*] Usando INSTALL_SUDO_PASSWORD já definido no ambiente.\n"
    return 0
  fi
  if [[ ! -t 0 ]]; then
    return 0
  fi
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    return 0
  fi

  printf "Usar sudo automático (export INSTALL_SUDO_PASSWORD) nesta instalação? [s/N] "
  local ans
  read -r ans
  case "$ans" in
    [sS]|[sS][iI][mM])
      printf "Senha sudo: "
      read -rs INSTALL_SUDO_PASSWORD
      printf '\n'
      if [[ -z "$INSTALL_SUDO_PASSWORD" ]]; then
        printf "[AVISO] Senha vazia — sudo será pedido normalmente.\n"
        return 0
      fi
      export INSTALL_SUDO_PASSWORD
      printf "[OK] INSTALL_SUDO_PASSWORD definido para esta sessão de instalação.\n"
      ;;
    *)
      printf "[*] sudo será solicitado normalmente quando necessário.\n"
      ;;
  esac
}

sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    if [[ "$1" == "-S" || "$1" == "-A" || "$1" == "-n" || "$1" == "-v" ]]; then
      command sudo "$@"
    else
      command sudo -H "$@"
    fi
    return $?
  fi
  if [[ -n "${INSTALL_SUDO_PASSWORD:-}" ]]; then
    printf '%s\n' "$INSTALL_SUDO_PASSWORD" | command sudo -S "$@"
  elif [[ -n "${SUDO_ASKPASS:-}" ]]; then
    export DISPLAY="${DISPLAY:-:0}"
    command sudo -A "$@"
  else
    command sudo "$@"
  fi
}
export -f sudo

# Grava ficheiro em path root sem heredoc+tee (sudo -S consome stdin e corrompe o ficheiro).
sudo_write_file() {
  local dest="$1"
  local tmp
  tmp="$(mktemp)"
  cat >"$tmp"
  sudo mkdir -p "$(dirname "$dest")"
  sudo cp "$tmp" "$dest"
  rm -f "$tmp"
}
export -f sudo_write_file

# Append stdin to root-owned file (evita sudo -S + tee corromper com a senha).
sudo_append_to_file() {
  local dest="$1"
  local tmp
  tmp="$(mktemp)"
  if sudo test -f "$dest" 2>/dev/null; then
    sudo cat "$dest" >"$tmp"
  fi
  cat >>"$tmp"
  sudo cp "$tmp" "$dest"
  rm -f "$tmp"
}
export -f sudo_append_to_file

# Sub-scripts: só valida sudo se a senha já veio do processo pai.
if [[ -n "${INSTALL_SUDO_PASSWORD:-}" ]] || [[ -n "${SUDO_ASKPASS:-}" && -x "${SUDO_ASKPASS}" ]]; then
  install_sudo_init
fi
