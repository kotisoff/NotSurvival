local properties = require "shared/utils/declarations/properties"
local utils = require "shared/utils/not_utils".utils

local module = {}

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

-- =================processing=food=data====================

local food_data_keys = {
  food = "food",
  saturation = "saturation",
  eat_anyway = "eat-anyway",
  eat_delay = "eat-delay",
  consume_item = "consume-item",
  replace_item = "replace-item"
}

local food_data_defaults = {
  food = 0,
  saturation = 0,
  food_type = "food",
  eat_delay = 1.5,
  consume_item = true
}

---@param data food_data
local function process_food_data(data, prop)
  for data_key, prop_key in pairs(food_data_keys) do
    local d = data[data_key]
    local p = prop[prop_key]
    local def = food_data_defaults[data_key]

    local val
    if type(p) ~= "nil" then
      val = p
    elseif type(d) ~= "nil" then
      val = d
    else
      val = def
    end

    data[data_key] = val
  end
  data.food_type = data.food_type or prop.type
  data.replace_item = utils.index_item(data.replace_item)

  if prop.callback then
    local cb = utils.parse_function_string(prop.callback)

    local tmp = data.callback
    data.callback = function(pid)
      if tmp then tmp(pid) end
      cb(pid)
    end
  end
end

---@param data food_data
local function process_potion_data(data, prop)
  data.food_type = data.food_type or "drink";
  data.eat_anyway = data.eat_anyway or true;

  local function cb(pid)
    -- TODO: Импельментировать тут эффекты
    debug.warning("not_survival: effects aren't implemeted yet.")
  end

  local tmp = data.callback
  data.callback = function(pid)
    if tmp then tmp(pid) end
    cb(pid)
  end
end

local food_processors = {
  ["not_survival:potion"] = process_potion_data,
  ["not_survival:food"] = process_food_data
}


-- =========================================================

local food_cache = {}

function module.flush_cache()
  food_cache = {}
end

---@return food_data|nil
function module.get_food_data(itemid)
  local key = tohex(itemid)
  if food_cache[key] then
    return table.deep_copy(food_cache[key])
  end

  ---@type food_data
  local data = { food = 0, saturation = 0 }
  local flag = false

  local props = item.properties[itemid]
  for prop_key, func in pairs(food_processors) do
    local prop = props[prop_key]
    if prop then
      flag = true
      func(data, prop)
    end
  end
  if not flag then return end

  food_cache[key] = data
  return table.deep_copy(data)
end

return module
