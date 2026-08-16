-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Start Telegram and Chromium (default profile) on workspace 1.
-- Browser opens first; Telegram opens second and is nudged to the right tile.
o.exec_on_start("[workspace 1 silent] uwsm-app -- Telegram")
o.exec_on_start("[workspace 1 silent] uwsm-app -- chromium --profile-directory=Default")

-- Start Yandex Music in the hidden special workspace. Playback stays paused
-- until requested from the Omarchy bar plugin.
o.exec_on_start("$HOME/.config/omarchy/plugins/vv.yandex-music/scripts/start-hidden.sh")
