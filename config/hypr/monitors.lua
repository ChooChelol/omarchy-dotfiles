-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- 2K main monitor: Xiaomi Mi Monitor on DP-3, right side.
-- Secondary monitor: HDMI-A-1, disabled by default.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "HDMI-A-1", disabled = true })
hl.monitor({ output = "DP-3", mode = "2560x1440@180", position = "1920x0", scale = omarchy_monitor_scale })

-- Good compromise for 27" or 32" 4K monitors (but fractional!)
-- local omarchy_gdk_scale = 2
-- local omarchy_monitor_scale = 1.6

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
