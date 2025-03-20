local time_item = sbar.add('item', {
  position = 'right',
  update_freq = 1,
  popup = {
    align = 'center',
  },
})

time_item:subscribe('routine', function(_)
  time_item:set({
    label = {
      string = os.date('%H:%M:%S')
    }
  })
end)

time_item:subscribe('mouse.entered', function(_)
  time_item:set({ popup = { drawing = 'on' } })
end)
time_item:subscribe('mouse.exited', function(_)
  time_item:set({ popup = { drawing = 'off' } })
end)
time_item:subscribe('mouse.exited.global', function(_)
  time_item:set({ popup = { drawing = 'off' } })
end)

local date_item = sbar.add('item', {
  position = 'popup.' .. time_item.name,
  update_freq = 60,
})

local function date_update(_)
  date_item:set({
    label = {
      string = os.date('%a %d %b')
    }
  })
end

date_item:subscribe('routine', date_update)
date_item:subscribe('forced', date_update)

date_item:subscribe('mouse.clicked', function(_)
  time_item:set({
    popup = {
      drawing = 'hide'
    }
  })
  os.execute('open -a "Calendar"')
end)
