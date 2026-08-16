# vv.yandex-music

Локальный Omarchy 4.0/Quickshell плагин управления Яндекс Музыкой через MPRIS.

## Возможности

- Трек и исполнитель в панели.
- Popup с обложкой, альбомом и кнопками управления.
- ЛКМ: play/pause.
- СКМ: следующий трек.
- ПКМ: открыть/закрыть popup.
- Колесо: предыдущий/следующий трек.
- Если MPRIS-плеера нет, клик запускает отдельный `yandex-music` desktop app скрыто.
- Окно всегда размещается на скрытом `special:yandex-music` и никогда не появляется на обычном workspace; процесс и MPRIS работают в фоне.
- Принимается только MPRIS identity `YandexMusic`; Chromium и YouTube полностью игнорируются.
- При cold start, когда официальный MPRIS возвращает `NoTrack` и `CanPlay=false`, кнопка Play инициализирует Vibe player через локальный CDP fallback; после этого управление снова идёт через MPRIS.

## Команды

```bash
omarchy plugin validate ~/.config/omarchy/plugins/vv.yandex-music
omarchy plugin enable vv.yandex-music --before omarchy.audio
omarchy plugin disable vv.yandex-music
omarchy shell yandex-music status
omarchy restart shell
```

## Локальный клиент

Исполняемый файл: `~/.local/bin/yandex-music`.
Приложение: `~/.local/opt/yandex-music/`.
Desktop entry: `~/.local/share/applications/yandexmusic.desktop`.
Hidden launcher: `scripts/start-hidden.sh`.
Cold-start fallback: `scripts/play-pause.sh` + `scripts/play-pause.mjs`.
CDP endpoint: `127.0.0.1:9223` only; it is not exposed to the network.

Клиент собран из AUR-рецепта `yandex-music` 5.109.1. Исходный `.deb` загружен с официального Yandex S3, SHA-256 проверен при сборке. Установка локальная, без root.
