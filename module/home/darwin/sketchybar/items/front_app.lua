local char_width <const> = 9

local front_app = sbar.add('item', {
  position = 'left',
  background = {
    padding_left = 0,
  },
  icon = {
    drawing = false,
  },
  scroll_texts = 'on',
  label = {
    width = char_width * 10,
    max_chars = 10,
  },
})

front_app:subscribe('front_app_switched', function(env)
  front_app:set({
    label = {
      string = env.INFO
    }
  })
end)
