local variables = require "player/variables";
local not_utils = require "utility/utils";
local movement = require "player/movement_controller";

local eating_sounds = {
  "not_survival/random/eat1",
  "not_survival/random/eat2",
  "not_survival/random/eat3"
}
local burp_sound = "not_survival/random/burp"
local drink_sound = "not_survival/random/drink"

local eating_players = {};

local hunger = {};

function hunger.get(pid)
  return variables.get_player_data(pid).hunger;
end

function hunger.get_saturation(pid)
  return variables.get_player_data(pid).saturation;
end

function hunger.get_max(pid)
  return variables.get_player_attributes(pid).hunger;
end

function hunger.get_max_saturation(pid)
  return variables.get_player_attributes(pid).saturation;
end

function hunger.set(pid, amount)
  local max = hunger.get_max(pid);
  ---@diagnostic disable-next-line: undefined-field
  variables.get_player_data(pid).hunger = math.clamp(amount, 0, max);
end

function hunger.set_saturation(pid, amount)
  local max = hunger.get_max_saturation(pid);
  ---@diagnostic disable-next-line: undefined-field
  variables.get_player_data(pid).saturation = math.clamp(amount, 0, max);
end

-- Feed player to his max.
function hunger.full(pid)
  local max_values = variables.get_player_attributes(pid);
  hunger.set(pid, max_values.hunger);
  hunger.set_saturation(pid, max_values.saturation);
end

function hunger.add(pid, hungerlevel, saturation)
  local hungerval = hunger.get(pid) + (hungerlevel or 0);
  local saturval = hunger.get_saturation(pid) + (saturation or 0);

  hunger.set(pid, hungerval);
  hunger.set_saturation(pid, saturval);
end

-- Consumes saturation
function hunger.consume(pid, amount)
  local data = variables.get_player_data(pid);
  local saturation = data.saturation;

  local value = saturation - amount;
  if value < 0 then
    local valueAbs = math.abs(value);
    local max = hunger.get_max(pid);

    local consumed = 1;
    if valueAbs >= max then
      consumed = math.ceil(valueAbs / max)
    end

    hunger.add(pid, consumed * -1);
  else
    data.saturation = value;
  end
end

---@param food_type food_type
---@return string
local function get_eating_sound(food_type)
  if food_type == "food" then
    return eating_sounds[math.random(#eating_sounds)];
  else
    return drink_sound
  end
end

local function get_selected_item(pid)
  return inventory.get(player.get_inventory(pid))
end;

---@alias food_type
---| '"food"' # Food like bread or apple,
---| '"drink"' # Potions and other drinks.

---@class food_data
---@field food number Number of hunger units will be replenished
---@field saturation number Number of saturation units will be replenished
---@field eat_anyway? boolean Eat even if not hungry. Default: false
---@field eat_delay? number Number of seconds of eating. Default: 1.5
---@field consume_item? boolean Consume food after eating. Default: true
---@field replace_item? number Index of item to replace food after eating. Only if consume_item is true. Default: nil
---@field food_type? food_type Type of food. Default: "food"
---@field callback? fun(pid) Callback after eating. Default: nil

---@deprecated Use user-props instead.
---@param pid number Player id
---@param data food_data
function hunger.eat(pid, data)
  if eating_players[pid] then return end;

  if hunger.get(pid) >= hunger.get_max(pid) and not data.eat_anyway
  then
    return
  end

  not_utils.create_coroutine(function()
    movement.set_speed_limit(2.5);

    eating_players[pid] = true;

    local selected_item = get_selected_item(pid);

    local state = not_utils.sleep_with_break(
      data.eat_delay or 1.5,
      function() return not input.is_active("player.build") or selected_item ~= get_selected_item(pid) end,
      function(temp)
        local speaker = temp.speaker;
        if not speaker or audio.get_volume(speaker) <= 0 then
          temp.speaker = audio.play_sound_2d(
            get_eating_sound(data.food_type or "food"),
            0.7,
            1,
            "regular"
          )
        end
      end
    );

    movement.set_speed_limit();

    if not state then goto stop_eating end;

    hunger.add(pid, data.food, data.saturation);

    if data.consume_item or true then
      local invid, slot = player.get_inventory(pid);
      local itemid, count = inventory.get(invid, slot);
      inventory.set(invid, slot, itemid, count - 1);
      if data.replace_item then
        inventory.add(invid, data.replace_item, 1)
      end
    end

    pcall(data.callback, pid);

    not_utils.random_cb(0.5,
      function()
        audio.play_sound_2d(burp_sound, 0.35, 1, "regular");
      end
    )

    ::stop_eating::

    -- Cooldown
    not_utils.sleep(0.2);
    eating_players[pid] = false;
  end)
end

return hunger;
