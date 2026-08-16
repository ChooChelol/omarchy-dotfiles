# Omarchy Dotfiles

[![check](https://github.com/ChooChelol/omarchy-dotfiles/actions/workflows/check.yml/badge.svg)](https://github.com/ChooChelol/omarchy-dotfiles/actions/workflows/check.yml)

Личные настройки Omarchy 4.0 quattro для быстрого восстановления после переустановки.

## Что хранится

- Hyprland Lua overrides: монитор, input, bindings, внешний вид, autostart.
- Omarchy Shell layout и idle settings.
- Пользовательская тема `comfyui-temp-uavpr-00022` без ComfyUI metadata.
- Плагин панели `vv.yandex-music`:
  - отдельный MPRIS source `YandexMusic`;
  - Chromium/YouTube игнорируются;
  - скрытый запуск на `special:yandex-music`;
  - cold-start fallback через CDP только на `127.0.0.1:9223`.
  - отдельный регулятор громкости PipeWire stream `yandexmusic`, 0–150% + mute.

## Не хранится

- токены, API keys, cookies, browser profiles;
- SSH/GPG keys;
- аккаунт и состояние Yandex Music;
- cache и `~/.local/state`;
- бинарники приложений;
- Hermes credentials/config.

## Быстрое восстановление

На свежей Omarchy quattro:

```bash
git clone https://github.com/ChooChelol/omarchy-dotfiles.git ~/omarchy-dotfiles
cd ~/omarchy-dotfiles
./scripts/restore.sh
```

Скрипт:

1. Проверяет Omarchy quattro.
2. Делает backup заменяемых файлов в:
   `~/.local/state/omarchy-dotfiles/backups/<timestamp>/`.
3. При необходимости предлагает установить AUR-пакеты через `yay`.
4. Копирует настройки, тему и plugin.
5. Проверяет Lua, JSON, shell scripts и plugin manifest.
6. Применяет `Tokyo Night`, включает plugin слева, перезагружает Hyprland и Omarchy Shell.

Музыка автоматически не начинает играть после входа. Yandex Music запускается скрыто; Play нажимается вручную на панели.

### Опции

```bash
./scripts/restore.sh --no-packages   # не ставить AUR-пакеты
./scripts/restore.sh --no-apply      # скопировать, но не reload/apply
./scripts/restore.sh --target-home /tmp/test-home --no-packages --no-apply
```

## Обновление snapshot

После изменения локальных настроек:

```bash
cd ~/omarchy-dotfiles
./scripts/update-snapshot.sh
./scripts/check.sh
git diff
git add -A
git commit -m "chore: update Omarchy snapshot"
git push
```

`update-snapshot.sh` использует строгий allowlist. Он не копирует весь `~/.config` и не переносит `.git` вложенного plugin.

## Hardware-specific

`config/hypr/monitors.lua` рассчитан на текущую схему:

- `DP-3`: `2560x1440@180`, позиция `1920x0`, scale `1`;
- `HDMI-A-1`: disabled.

После установки на другой ПК поправить этот файл до запуска restore либо после него.

## Требования

- Omarchy 4.0 quattro;
- `git`, `bash`, `jq`, `lua/luac`;
- `yay` для `yandex-music`;
- Node.js и curl для cold-start fallback plugin.

## Лицензия

MIT. Wallpaper/generated image может иметь отдельные права в зависимости от исходного материала.
