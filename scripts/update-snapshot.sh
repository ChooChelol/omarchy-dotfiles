#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
SOURCE_HOME=${HOME}

copy_file() {
  local src=$1 rel=$2
  [[ -f $src ]] || { echo "missing source: $src" >&2; exit 1; }
  mkdir -p -- "$(dirname -- "$ROOT/$rel")"
  cp -- "$src" "$ROOT/$rel"
}

for name in hyprland monitors input bindings looknfeel autostart; do
  copy_file "$SOURCE_HOME/.config/hypr/$name.lua" "config/hypr/$name.lua"
done
copy_file "$SOURCE_HOME/.config/omarchy/shell.json" "config/omarchy/shell.json"

plugin_src="$SOURCE_HOME/.config/omarchy/plugins/vv.yandex-music"
plugin_dst="$ROOT/config/omarchy/plugins/vv.yandex-music"
rm -rf -- "${plugin_dst:?}"
mkdir -p -- "$plugin_dst/scripts" "$plugin_dst/tests"
for name in manifest.json Service.qml BarWidget.qml MediaModel.js README.md; do
  copy_file "$plugin_src/$name" "config/omarchy/plugins/vv.yandex-music/$name"
done
for name in start-hidden.sh play-pause.sh play-pause.mjs; do
  copy_file "$plugin_src/scripts/$name" "config/omarchy/plugins/vv.yandex-music/scripts/$name"
done
copy_file "$plugin_src/tests/volume-model.test.cjs" "config/omarchy/plugins/vv.yandex-music/tests/volume-model.test.cjs"
chmod 0755 "$plugin_dst/scripts/start-hidden.sh" "$plugin_dst/scripts/play-pause.sh"
chmod 0644 "$plugin_dst/scripts/play-pause.mjs"

theme=comfyui-temp-uavpr-00022
theme_src="$SOURCE_HOME/.config/omarchy/themes/$theme"
theme_dst="$ROOT/config/omarchy/themes/$theme"
rm -rf -- "${theme_dst:?}"
mkdir -p -- "$theme_dst/backgrounds"
copy_file "$theme_src/colors.toml" "config/omarchy/themes/$theme/colors.toml"
copy_file "$theme_src/icons.theme" "config/omarchy/themes/$theme/icons.theme"
command -v magick >/dev/null || { echo "ImageMagick required to strip PNG metadata" >&2; exit 1; }
magick "$theme_src/backgrounds/ComfyUI_temp_uavpr_00022_.png" -strip \
  "$theme_dst/backgrounds/ComfyUI_temp_uavpr_00022_.png"

omarchy theme current > "$ROOT/config/omarchy/current-theme.txt"
"$ROOT/scripts/check.sh"
printf 'Snapshot updated. Review with: git diff\n'
