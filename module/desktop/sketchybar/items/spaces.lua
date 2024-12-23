local spaces = {}

local background = defaults.theme.base01
local foreground = defaults.theme.base06

sbar.add('event', 'aerospace_workspace_change')

local function space_changed(env)
  local index = spaces[env.NAME]
  if index == tonumber(env.FOCUSED_WORKSPACE) then
    sbar.set(env.NAME, {
      background = { color = foreground, },
      icon = { color = background, },
      label = { color = background, },
    })
  else
    sbar.set(env.NAME, {
      background = { color = background, },
      icon = { color = foreground, },
      label = { color = foreground, },
    })
  end
end

-- local function space_clicked(env)
--   sbar.exec('aerospace workspace ' .. spaces[env.NAME])
-- end
-- 
-- local function space_mouse_entered(env)
--   sbar.set(env.NAME, {
--     background = { border_color = foreground, }
--   })
-- end
-- 
-- local function space_mouse_exited(env)
--   sbar.set(env.NAME, {
--     background = { border_color = background, }
--   })
-- end

for i = 1,9,1
do
  local lb_pad = 0
  local rb_pad = 0
  if i == 1 then
    lb_pad = defaults.padding
  end
  if i == 9 then
    rb_pad = defaults.padding
  end
  local space = sbar.add('item', {
    background = {
      color = background,
      height = defaults.bar.height,
      padding_left = lb_pad,
      padding_right = rb_pad,
    },
    icon = {
      padding_left = 0,
      padding_right = 0,
    },
    label = {
      padding_left = 10,
      padding_right = 10,
      string = "" .. i,
      color = foreground,
    }
  })
  space:subscribe('aerospace_workspace_change', space_changed)
  -- space:subscribe('mouse.clicked', space_clicked)
  -- space:subscribe('mouse.entered', space_mouse_entered)
  -- space:subscribe('mouse.exited', space_mouse_exited)
  spaces[space.name] = i
end

local keys = {}
for name,_ in pairs(spaces) do
  table.insert(keys, name)
end

sbar.add('bracket', keys, { background = { color = background, height = defaults.bar.height }, })
