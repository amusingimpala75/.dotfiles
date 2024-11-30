sbar = require('sketchybar')

sbar.begin_config()

sbar.default({
  updates = "when_shown",
  -- icon = {},
  label = {
    font = defaults.font.fixed .. ':Bold:' .. tostring(defaults.font.size),
    color = defaults.theme.base05,
  },
})

sbar.bar({
  height = defaults.bar.height,
  color = defaults.theme.base01,
  position = defaults.bar.position,
  display = 'all',
})

require('items.front_app')

sbar.end_config()

sbar.event_loop()