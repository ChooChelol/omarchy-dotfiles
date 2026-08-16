#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if ! curl -fsS http://127.0.0.1:9223/json/list >/dev/null 2>&1; then
  "$SCRIPT_DIR/start-hidden.sh"
fi

for _ in $(seq 1 100); do
  curl -fsS http://127.0.0.1:9223/json/list >/dev/null 2>&1 && break
  sleep 0.1
done

# The official app renders its Vibe button before the player backend becomes
# ready. An early click is accepted by the DOM but discarded by the backend.
# Retry only while MPRIS still reports NoTrack/canTogglePlaying=false.
for _ in $(seq 1 8); do
  status=$(omarchy shell yandex-music status 2>/dev/null || true)
  [[ $status == *'"playing":true'* ]] && exit 0

  if [[ $status == *'"canTogglePlaying":true'* ]]; then
    omarchy shell yandex-music playPause >/dev/null
  else
    node "$SCRIPT_DIR/play-pause.mjs"
  fi

  for _ in $(seq 1 30); do
    status=$(omarchy shell yandex-music status 2>/dev/null || true)
    [[ $status == *'"playing":true'* ]] && exit 0
    if [[ $status == *'"canTogglePlaying":true'* ]]; then
      omarchy shell yandex-music playPause >/dev/null
      for _ in $(seq 1 20); do
        status=$(omarchy shell yandex-music status 2>/dev/null || true)
        [[ $status == *'"playing":true'* ]] && exit 0
        sleep 0.1
      done
      exit 1
    fi
    sleep 0.1
  done
done

exit 1
