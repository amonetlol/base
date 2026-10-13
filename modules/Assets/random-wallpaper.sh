#!/usr/bin/env bash
# Escolhe uma imagem em ~/Imagens/wallpapers e aplica no Plasma.
set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Imagens/wallpapers}"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/random-wallpaper.last"
uid="$(id -u)"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${uid}}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"

if [[ ! -d "$WALL_DIR" ]]; then
  echo "Pasta não encontrada: $WALL_DIR" >&2
  exit 1
fi

mapfile -d '' files < <(find "$WALL_DIR" -type f \( \
  -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
\) -print0)

if ((${#files[@]} == 0)); then
  echo "Nenhuma imagem em $WALL_DIR" >&2
  exit 1
fi

pick="${files[RANDOM % ${#files[@]}]}"
if [[ -f "$STATE" && ${#files[@]} -gt 1 ]]; then
  last="$(<"$STATE")"
  tries=0
  while [[ "$pick" == "$last" && "$tries" -lt 12 ]]; do
    pick="${files[RANDOM % ${#files[@]}]}"
    tries=$((tries + 1))
  done
fi
printf '%s\n' "$pick" > "$STATE"

if ! command -v qdbus6 >/dev/null 2>&1; then
  echo "qdbus6 não encontrado" >&2
  exit 1
fi

if ! qdbus6 org.kde.plasmashell >/dev/null 2>&1; then
  echo "Plasma ainda não está na sessão; wallpaper não aplicado."
  exit 0
fi

js_path="$(python3 -c 'import json, pathlib, sys; print(json.dumps(pathlib.Path(sys.argv[1]).as_posix()))' "$pick")"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
  var d = allDesktops[i];
  d.wallpaperPlugin = 'org.kde.image';
  d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
  d.writeConfig('Image', ${js_path});
  d.writeConfig('SlidePaths', '');
}
" >/dev/null

echo "Wallpaper: $pick"
