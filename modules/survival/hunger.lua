local api = require "api";
local variables = api.variables;
local not_utils = api.utils;
local movement = api.movement;

local eating_sounds = {
  "not_survival/random/eat1",
  "not_survival/random/eat2",
  "not_survival/random/eat3"
}

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
  variables.get_player_data(pid).hunger = amount;
end

function hunger.set_saturation(pid, amount)
  variables.get_player_data(pid).saturation = amount;
end

-- Feed player to his max.
function hunger.full(pid)
  local max_values = variables.get_player_attributes(pid);
  hunger.add(pid, max_values.hunger, max_values.saturation);
end

function hunger.add(pid, hungerlevel, saturation)
  local hungerval = hunger.get(pid) + (hungerlevel or 0);
  local saturval = hunger.get_saturation(pid) + (saturation or 0);

  local playerdata = variables.get_player_data(pid);
  playerdata.hunger = hungerval;
  playerdata.saturation = saturval;
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

local function get_random_eating_sound()
  return eating_sounds[math.random(#eating_sounds)];
end

---@param pid number Player id
---@param foodlevel number Amount of food to add
---@param saturation number Amount of saturation to add
---@param eat_delay number|nil How many seconds will item be used
---@param consume_item boolean|nil Will item be consumed?
---@param eat_anyway boolean|nil Eat item even if player is not hungry
---@param callback function|nil Callback after eating.
function hunger.eat(pid, foodlevel, saturation, eat_delay, consume_item, eat_anyway, callback)
  if eating_players[pid] then return end;

  if hunger.get(pid) >= hunger.get_max(pid) and not eat_anyway
  then
    return
  end

  callback = callback or function(player_id) end

  not_utils.create_coroutine(function()
    movement.set_speed_limit(2.5);

    eating_players[pid] = true;

    local state = not_utils.sleep_with_break(
      eat_delay or 1.5,
      function() return not input.is_active("player.build") end,
      function(temp)
        local speaker = temp.speaker;
        if not speaker or audio.get_volume(speaker) <= 0 then
          temp.speaker = audio.play_sound_2d(
            get_random_eating_sound(),
            0.7,
            1,
            "regular"
          )
        end
      end
    );

    movement.set_speed_limit();

    if not state then goto stop_eating end;

    hunger.add(pid, foodlevel, saturation);

    if consume_item or true then
      local invid, slot = player.get_inventory(pid);
      local itemid, count = inventory.get(invid, slot);
      inventory.set(invid, slot, itemid, count - 1);
    end

    callback(pid);

    ::stop_eating::

    -- Cooldown
    not_utils.sleep(0.1);
    eating_players[pid] = false;
  end)
end

return hunger;
