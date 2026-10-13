#!/usr/bin/env bash
# Instala ~/.bin/random-wallpaper.sh e o timer systemd do usuário.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSET_DIR="${SCRIPT_DIR}/Assets"
SRC_SCRIPT="${ASSET_DIR}/random-wallpaper.sh"
SRC_SERVICE="${ASSET_DIR}/random-wallpaper.service"
SRC_TIMER="${ASSET_DIR}/random-wallpaper.timer"

BIN_DIR="${HOME}/.bin"
UNIT_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"
DEST_SCRIPT="${BIN_DIR}/random-wallpaper.sh"
DEST_SERVICE="${UNIT_DIR}/random-wallpaper.service"
DEST_TIMER="${UNIT_DIR}/random-wallpaper.timer"

for src in "$SRC_SCRIPT" "$SRC_SERVICE" "$SRC_TIMER"; do
  if [[ ! -f "$src" ]]; then
    echo "Arquivo de origem não encontrado: ${src}" >&2
    exit 1
  fi
done

mkdir -p "$BIN_DIR" "$UNIT_DIR"

sed 's/\r$//' "$SRC_SCRIPT" > "$DEST_SCRIPT"
chmod +x "$DEST_SCRIPT"
sed 's/\r$//' "$SRC_SERVICE" > "$DEST_SERVICE"
sed 's/\r$//' "$SRC_TIMER" > "$DEST_TIMER"

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"

systemctl --user daemon-reload

for old in randow-wallpapers.service random-wallpapers.service \
  randow-wallpapers.timer random-wallpapers.timer; do
  systemctl --user disable --now "$old" 2>/dev/null || true
done

systemctl --user enable --now random-wallpaper.timer
systemctl --user start random-wallpaper.service

echo "Instalado: ${DEST_SCRIPT}"
echo "Serviço: ${DEST_SERVICE}"
echo "Timer: ${DEST_TIMER}"
systemctl --user --no-pager --full status random-wallpaper.service || true
