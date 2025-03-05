sbar = require('sketchybar')

sbar.begin_config()

local background_color = defaults.theme.base01;
local padding = 4;

sbar.default({
  updates = "when_shown",
  -- icon = {},
  label = {
    font = defaults.font.fixed .. ':Bold:' .. tostring(defaults.font.size),
    color = defaults.theme.base05,
    padding_left = padding,
    padding_right = padding,
  },
  popup = {
    background = {
      color = background_color,
      padding_left = padding,
      padding_right = padding,
      border_color = defaults.border.color,
      border_width = defaults.border.width / 2,
    },
  },
})

sbar.bar({
  height = defaults.bar.height,
  color = background_color,
  position = defaults.bar.position,
  display = 'all',
})

-- Left Items
require('items.front_app')
require('items.spaces')

-- Right Items
require('items.time')
require('items.water')

sbar.end_config()

sbar.event_loop()
