#!/bin/bash
set -euo pipefail

APP=$(command -v yandex-music || true)
if [[ -z $APP ]]; then
  echo "yandex-music is not installed" >&2
  exit 127
fi

has_yandex_mpris() {
  local name identity
  while read -r name _; do
    [[ $name == org.mpris.MediaPlayer2.* ]] || continue
    identity=$(busctl --user get-property "$name" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2 Identity 2>/dev/null || true)
    [[ $identity == 's "YandexMusic"' ]] && return 0
  done < <(busctl --user list --no-legend)
  return 1
}

# Already running in background: do not summon its window.
has_yandex_mpris && exit 0

# Hyprland rule sends YandexMusic to special:yandex-music silently, so its
# Electron window never appears on a normal workspace. Keeping the hidden
# window alive is more reliable for MPRIS/audio than closing it after startup.
hyprctl dispatch "hl.dsp.exec_cmd([[$APP --remote-debugging-address=127.0.0.1 --remote-debugging-port=9223]])" >/dev/null
