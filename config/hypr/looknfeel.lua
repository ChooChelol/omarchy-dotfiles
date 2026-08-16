-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- 2px gaps between windows.
    gaps_in = 2,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 4,

    -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
    -- dim_inactive = true,
    -- dim_strength = 0.15,
  },
})

-- Window opacity: active 0.95, inactive 0.92.
-- Overrides Omarchy's default (0.985/0.96). Adjust to taste.
o.window(".*", { opacity = "0.95 0.92" })

-- Keep Yandex Music's Electron window off normal workspaces. The app remains
-- available through MPRIS and the Omarchy bar plugin.
o.window("YandexMusic", { workspace = "special:yandex-music silent" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
