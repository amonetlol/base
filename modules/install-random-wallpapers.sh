#!/usr/bin/env bash
# Instala ~/.bin/random-wallpapers.sh e ativa o serviço systemd do usuário.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_SCRIPT="${SCRIPT_DIR}/randow-wallpapers.sh"
SRC_SERVICE="${SCRIPT_DIR}/randow-wallpapers.service"

BIN_DIR="${HOME}/.bin"
UNIT_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"
DEST_SCRIPT="${BIN_DIR}/random-wallpapers.sh"
DEST_UNIT="${UNIT_DIR}/random-wallpapers.service"
UNIT_NAME="random-wallpapers.service"
OLD_UNIT="randow-wallpapers.service"

if [[ ! -f "$SRC_SCRIPT" ]]; then
  echo "Script de origem não encontrado: ${SRC_SCRIPT}" >&2
  exit 1
fi
if [[ ! -f "$SRC_SERVICE" ]]; then
  echo "Service de origem não encontrado: ${SRC_SERVICE}" >&2
  exit 1
fi

mkdir -p "$BIN_DIR" "$UNIT_DIR"

sed 's/\r$//' "$SRC_SCRIPT" > "$DEST_SCRIPT"
chmod +x "$DEST_SCRIPT"

sed -e 's/\r$//' \
  -e 's|%h/\.bin/randow-wallpapers\.sh|%h/.bin/random-wallpapers.sh|' \
  "$SRC_SERVICE" > "$DEST_UNIT"

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"

systemctl --user daemon-reload

if systemctl --user list-unit-files --no-legend "${OLD_UNIT}" 2>/dev/null | grep -q .; then
  systemctl --user disable --now "${OLD_UNIT}" 2>/dev/null || true
fi

systemctl --user enable --now "${UNIT_NAME}"

echo "Instalado: ${DEST_SCRIPT}"
echo "Serviço: ${DEST_UNIT}"
systemctl --user --no-pager --full status "${UNIT_NAME}" || true
