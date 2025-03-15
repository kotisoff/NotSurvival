---@diagnostic disable: undefined-field

local resource = require "utility/resource_func"
local api = require "api";
local Registry = api.registry;
local hunger = api.survival.hunger
local not_utils = api.utils.utils;

local function process_food(prop, data)
  local callback = nil;

  if prop.callback then
    callback = not_utils.parse_callback_string(prop.callback);
  end;

  ---@type food_data
  local temp = {
    food = prop.food or 0,
    saturation = prop.saturation or 0,
    eat_anyway = prop["eat-anyway"],
    eat_delay = prop["eat-delay"],
    consume_item = prop["consume-item"],
    replace_item = not_utils.index_item(prop["replace-item"]),
    food_type = prop.type,
    callback = callback
  }

  for key, value in pairs(temp) do
    if type(value) ~= "nil" then
      data[key] = value;
    end
  end

  return data;
end

---@param prop {effect:string,level:number,duration:number}
---@param data food_data
---@return any
local function process_potion(prop, data)
  data.food_type = data.food_type or "drink";
  data.eat_anyway = data.eat_anyway or true;

  local function cb(pid)
    ---@type Effect
    local effect = Registry:get(Registry.TYPES.EFFECTS, prop.effect);
    effect:apply(pid, prop.level, prop.duration);
  end

  data.callback = cb;

  return data;
end

local properties = {
  ["not_survival:food"] = process_food,
  ["not_survival:potion"] = process_potion
}

local eating_players = {};

events.on(resource("player_tick"), function(pid, tps)
  -- Неболбшой костыль, чтоб ебанина ниже не циклилась постоянно во время зажатия пкм.
  if not input.is_active("player.build") then
    eating_players[pid] = false;
    return
  end
  if eating_players[pid] then return end;
  eating_players[pid] = true;

  local itemid = inventory.get(player.get_inventory(pid))
  local props = item.properties[itemid];

  ---@type food_data
  local data = { food = 0, saturation = 0 };

  local is_usable = false;
  for property, func in pairs(properties) do
    if props[property] then
      data = func(props[property], data)
      is_usable = true
    end;
  end

  if not is_usable then return end;

  ---@diagnostic disable-next-line: deprecated
  hunger.eat(pid, data)
end)
