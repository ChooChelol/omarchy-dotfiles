#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TARGET_HOME=${HOME}
INSTALL_PACKAGES=1
APPLY=1

usage() {
  printf '%s\n' \
    "Usage: $0 [--target-home PATH] [--no-packages] [--no-apply]" \
    "" \
    "  --target-home PATH  restore into another home (testing)" \
    "  --no-packages       skip AUR package installation" \
    "  --no-apply          skip theme/plugin enable and live reload"
}

while (($#)); do
  case "$1" in
    --target-home)
      [[ $# -ge 2 ]] || { echo "missing value for --target-home" >&2; exit 2; }
      TARGET_HOME=$2
      shift 2
      ;;
    --no-packages) INSTALL_PACKAGES=0; shift ;;
    --no-apply) APPLY=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

TARGET_HOME=$(realpath -m -- "$TARGET_HOME")
[[ $TARGET_HOME != / ]] || { echo "refusing target home /" >&2; exit 2; }

if [[ $TARGET_HOME != "$(realpath -m -- "$HOME")" ]]; then
  [[ $APPLY -eq 0 ]] || {
    echo "--target-home outside current HOME requires --no-apply" >&2
    exit 2
  }
  INSTALL_PACKAGES=0
fi

required_sources=(
  config/hypr/hyprland.lua
  config/hypr/monitors.lua
  config/hypr/input.lua
  config/hypr/bindings.lua
  config/hypr/looknfeel.lua
  config/hypr/autostart.lua
  config/omarchy/shell.json
  config/omarchy/current-theme.txt
  config/omarchy/themes/comfyui-temp-uavpr-00022
  config/omarchy/plugins/vv.yandex-music
)
for rel in "${required_sources[@]}"; do
  [[ -e $ROOT/$rel ]] || { echo "missing repository source: $rel" >&2; exit 1; }
done

if [[ $APPLY -eq 1 ]]; then
  [[ -f /usr/share/omarchy/default/hypr/bootstrap.lua ]] || {
    echo "Omarchy 4.0 quattro not detected" >&2
    exit 1
  }
  command -v omarchy >/dev/null || { echo "omarchy command not found" >&2; exit 1; }
fi

if [[ $INSTALL_PACKAGES -eq 1 ]]; then
  command -v yay >/dev/null || { echo "yay required for AUR packages" >&2; exit 1; }
  while IFS= read -r package; do
    [[ -n $package && $package != \#* ]] || continue
    if ! pacman -Q "$package" >/dev/null 2>&1; then
      yay -S --needed "$package"
    fi
  done < "$ROOT/packages/aur.txt"
fi

timestamp=$(date +%Y%m%d-%H%M%S)
backup="$TARGET_HOME/.local/state/omarchy-dotfiles/backups/$timestamp"
mkdir -p -- "$backup"

backup_one() {
  local rel=$1 src="$TARGET_HOME/$1" dst="$backup/$1"
  if [[ -e $src || -L $src ]]; then
    mkdir -p -- "$(dirname -- "$dst")"
    cp -a -- "$src" "$dst"
  fi
}

for rel in \
  .config/hypr/hyprland.lua \
  .config/hypr/monitors.lua \
  .config/hypr/input.lua \
  .config/hypr/bindings.lua \
  .config/hypr/looknfeel.lua \
  .config/hypr/autostart.lua \
  .config/omarchy/shell.json \
  .config/omarchy/themes/comfyui-temp-uavpr-00022 \
  .config/omarchy/plugins/vv.yandex-music; do
  backup_one "$rel"
done

mkdir -p -- "$TARGET_HOME/.config/hypr" "$TARGET_HOME/.config/omarchy"
for name in hyprland monitors input bindings looknfeel autostart; do
  install -m 0644 -- "$ROOT/config/hypr/$name.lua" "$TARGET_HOME/.config/hypr/$name.lua"
done
install -m 0644 -- "$ROOT/config/omarchy/shell.json" "$TARGET_HOME/.config/omarchy/shell.json"

for rel in \
  .config/omarchy/themes/comfyui-temp-uavpr-00022 \
  .config/omarchy/plugins/vv.yandex-music; do
  rm -rf -- "$TARGET_HOME/$rel"
  mkdir -p -- "$(dirname -- "$TARGET_HOME/$rel")"
  cp -a -- "$ROOT/config/${rel#.config/}" "$TARGET_HOME/$rel"
done

for file in "$TARGET_HOME"/.config/hypr/*.lua; do
  luac -p "$file"
done
jq -e . "$TARGET_HOME/.config/omarchy/shell.json" >/dev/null
jq -e . "$TARGET_HOME/.config/omarchy/plugins/vv.yandex-music/manifest.json" >/dev/null
bash -n "$TARGET_HOME/.config/omarchy/plugins/vv.yandex-music/scripts/start-hidden.sh"
bash -n "$TARGET_HOME/.config/omarchy/plugins/vv.yandex-music/scripts/play-pause.sh"
node --check "$TARGET_HOME/.config/omarchy/plugins/vv.yandex-music/scripts/play-pause.mjs"

if [[ $APPLY -eq 1 ]]; then
  omarchy plugin validate "$TARGET_HOME/.config/omarchy/plugins/vv.yandex-music"
  theme=$(<"$ROOT/config/omarchy/current-theme.txt")
  omarchy theme set "$theme"
  omarchy shell shell rescanPlugins >/dev/null
  omarchy plugin enable vv.yandex-music --before omarchy.audio
  hyprctl reload
  omarchy restart shell
fi

printf 'Restored into: %s\n' "$TARGET_HOME"
printf 'Backup: %s\n' "$backup"
if [[ $APPLY -eq 0 ]]; then
  printf 'Live apply skipped.\n'
fi
