local good = defaults.theme.base0D
local bad = defaults.theme.base0F

local duration = 2.5 * 60 -- 2:30 minutes

local water = sbar.add('item', {
    position = 'right',
    update_freq = 10, -- 10 seconds
    label = {
       string = "⬤",
       font = {
          style = 'Regular',
          size = 24,
       },
       color = good,
    },
})

local start = os.time()

local function shouldDrink()
    return os.difftime(os.time(), start) > duration
end

local function drink()
    start = os.time()
    water:set({label = { color = good } })
end

local function checkDrink()
    if shouldDrink()
    then
        water:set({label = { color = bad } })
    end
end

water:subscribe('mouse.clicked', drink)

water:subscribe('routine', checkDrink)
water:subscribe('forced', checkDrink)
