local sounds = require "shared/lib/sounds_registry"
local data = require "shared/player/data"

local module = {}

function module.get_hunger(pid)
  return data.get_data(pid, "hunger")
end

function module.get_max_hunger(pid)
  return data.get_attributes(pid, "hunger")
end

function module.get_saturation(pid)
  return data.get_data(pid, "saturation")
end

function module.get_max_saturation(pid)
  return data.get_attributes(pid, "saturation")
end

function module.set_hunger(pid, amount)
  local max = module.get_max_hunger(pid)
  data.set_field(pid, "data", "hunger", math.clamp(amount, 0, max))
end

function module.set_saturation(pid, amount)
  local max = module.get_max_saturation(pid)
  data.set_field(pid, "data", "saturation", math.clamp(amount, 0, max))
end

function module.full(pid)
  local max_h = module.get_max_hunger(pid)
  local max_s = module.get_max_saturation(pid)

  module.set_hunger(pid, max_h)
  module.set_saturation(pid, max_s)
end

function module.add(pid, hunger, saturation)
  local h = module.get_hunger(pid) + (hunger or 0)
  local s = module.get_saturation(pid) + (saturation or 0)

  module.set_hunger(pid, h)
  module.set_saturation(pid, s)
end

function module.consume(pid, amount)
  local s = module.get_saturation(pid)

  local new_s = s - amount
  if new_s < 0 then
    local abs_s = math.abs(new_s)
    local max_h = module.get_max_hunger(pid)

    module.set_saturation(pid, 0)

    local consumed = math.ceil(abs_s / max_h)
    if consumed < 1 then consumed = 1 end

    module.add(pid, -consumed)
  else
    module.set_saturation(pid, new_s)
  end
end

-- =========================================================

local _nu = require "shared/utils/not_utils"
local cor = _nu.coroutines
local eating_players = {}

---@alias food_type
---| '"food"' Bread or apple
---| '"drink"' Potions and other drinks

---@class food_data
---@field food number Number of hunger units will be replenished
---@field saturation number Number of saturation units will be replenished
---@field eat_anyway? boolean Eat even if not hungry. Default: false
---@field eat_delay? number Number of seconds of eating. Default: 1.5
---@field consume_item? boolean Consume food after eating. Default: true
---@field replace_item? number Index of item to replace food after eating. Only if consume_item is true.
---@field food_type? food_type Type of food. Default: "food"
---@field callback? fun(pid) Callback after eating.


---@param pid int
---@param food_data food_data
function module.eat(pid, food_data)
  local key = tohex(pid)

  if eating_players[key] then return end

  if module.get_hunger(pid) >= module.get_max_hunger(pid) and not food_data.eat_anyway then
    return
  end
end
