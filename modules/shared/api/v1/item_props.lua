local utils = require "shared/utils/not_utils".utils;
local config = require "shared/core/config";
local logger = require "shared/core/logger"

local processors = {};
local cache = {};
local defaults = {};

local module = {};

local function has_prop(item_id, prop_name)
  return (item.properties[item_id] or {})[prop_name] ~= nil;
end

--Converts keys from kebab-case to snake_case
local function kebab_to_snake(table)
  local t = {};
  for key, value in pairs(table) do
    local new_key = string.replace(key, "-", "_");
    t[new_key] = value;
  end

  return t;
end

-- ====================food=processor=======================

---@alias ns.types.food_type
---| '"food"' Bread or apple
---| '"drink"' Potions and other drinks

---@class ns.types.food
---@field food number Number of hunger units will be replenished
---@field saturation number Number of saturation units will be replenished
---@field food_type? ns.types.food_type Type of food. Default: "food"
---@field eat_delay? number Number of seconds of eating. Default: 1.5
---@field eat_anyway? boolean Eat even if not hungry. Default: false
---@field consume_item? boolean Consume food after eating. Default: true
---@field replace_item? number Index of item to replace food after eating. Only if consume_item is true.
---@field callback? fun(pid) Callback after eating.

---@type table<int, ns.types.food>
cache.food = {};

---@type ns.types.food
defaults.food = {
  food = 0,
  saturation = 0,
  food_type = "food",
  eat_delay = 1.5,
  eat_anyway = false,
  consume_item = true,
  replace_item = 0
}

function processors.food(item_id)
  if cache.food[item_id] then
    return table.copy(cache.food[item_id]);
  end

  local props = item.properties[item_id] or {};

  ---@type ns.types.food
  local food_props = kebab_to_snake(props[config.properties.food] or {});

  -- Ну по идее напитки можно выпить в любой момент, правда eay_anyway всё же решает.
  if food_props.food_type == "drink" and type(food_props.eat_anyway) == "nil" then
    food_props.eat_anyway = true;
  end

  for key, default_value in pairs(defaults.food) do
    if type(food_props[key]) == "nil" then
      food_props[key] = default_value;
    end
  end

  food_props.replace_item = utils.index_item(food_props.replace_item);

  if food_props.callback then
    ---@diagnostic disable-next-line: param-type-mismatch
    food_props.callback = utils.parse_function_string(food_props.callback);
  end

  cache.food[item_id] = food_props;

  return table.copy(food_props);
end

-- ===============effect=property=processor=================

---@class ns.types.effect
---@field id string Identifier of effect to apply
---@field level integer Effect strength level
---@field duration integer Amount of time effect will last in seconds

---@type table<int, ns.types.effect>
cache.effect = {};

---@type ns.types.effect
defaults.effect = {
  id = "If you have this message, you've fucked up item effect properties.",
  level = 1,
  duration = 30
};

function processors.effect(item_id)
  if cache.effect[item_id] then
    return table.copy(cache.effect[item_id]);
  end

  local props = item.properties[item_id] or {};

  ---@type ns.types.effect
  local effect_props = table.copy(props[config.properties.effect] or {});

  logger:println("W", "Effects are not implemented yet."); --TODO: implement effects

  for key, default_value in pairs(defaults.effect) do
    if type(effect_props[key]) == "nil" then
      effect_props[key] = default_value;
    end
  end

  cache.effect[item_id] = effect_props;

  return table.copy(effect_props);
end

-- ====================tool=processor=======================

---@class ns.types.tool
---@field type string[] Item tool types. Used in mineable tags table.
---@field speed integer Block destruction speed, if it is mineable with this tool.

---@type table<int, ns.types.tool>
cache.tool = {};

---@type ns.types.tool
defaults.tool = {
  type = {},
  speed = 1
};

function processors.tool(item_id)
  if cache.tool[item_id] then
    return table.deep_copy(cache.tool[item_id]);
  end

  local props = item.properties[item_id] or {};

  ---@type ns.types.tool
  local tool_props = table.copy(props[config.properties.tool] or {});

  for key, default_value in pairs(defaults.tool) do
    if type(tool_props[key]) == "nil" then
      tool_props[key] = default_value;
    end
  end

  cache.tool[item_id] = tool_props;

  return table.deep_copy(tool_props);
end

-- ===================weapon=processor======================

---@class ns.types.weapon
---@field type string[]
---@field damage number
---@field speed number

---@type table<int, ns.types.weapon>
cache.weapon = {};

---@type ns.types.weapon
defaults.weapon = {
  type = {},
  damage = config.player.combat.punch_damage,
  speed = config.player.combat.punch_cooldown
};

function processors.weapon(item_id)
  if cache.weapon[item_id] then
    return table.deep_copy(cache.weapon[item_id]);
  end

  local props = item.properties[item_id] or {};

  ---@type ns.types.weapon
  local weapon_props = table.copy(props[config.properties.weapon] or {});

  for key, default_value in pairs(defaults.weapon) do
    if type(weapon_props[key]) == "nil" then
      weapon_props[key] = default_value;
    end
  end

  cache.weapon[item_id] = weapon_props;

  return table.deep_copy(weapon_props);
end

-- ========================module===========================

module.get_food = processors.food;
module.get_effect = processors.effect;
module.get_tool = processors.tool;
module.get_weapon = processors.weapon;

function module.has_food(item_id)
  return has_prop(item_id, config.properties.food);
end

function module.has_effect(item_id)
  return has_prop(item_id, config.properties.effect);
end

function module.has_tool(item_id)
  return has_prop(item_id, config.properties.tool);
end

function module.has_weapon(item_id)
  return has_prop(item_id, config.properties.weapon);
end

return module;
