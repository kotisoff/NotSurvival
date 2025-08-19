---@diagnostic disable: inject-field
local resource = require "shared/utils/resource_func";
local player_data = require "shared/player/data_manager";
local experience = require "shared/lib/experience"

local bars_size = {};

local function exists(name)
  local status = pcall(function()
    return document[name].pos
  end)

  return status;
end

local function calculate_width(max_width, value, max)
  return math.floor(max_width * value / (max or value));
end

local function is_visible(name, value, max)
  local more_than_zero = (value > 0);
  local oxygen_visible = not (name == "oxygen" and value >= max)

  return more_than_zero and oxygen_visible
end

local function update_value(name, value, max)
  local label_id = name .. "_label";
  local bar_id = name .. "_bar";

  local visible = is_visible(name, value, max);

  if exists(label_id) then
    local label = document[label_id];

    local text = string.format("%s%s", value, max and "/" .. max or "");
    label.text = text;
    label.visible = visible;
  end
  if exists(bar_id) then
    local bar = document[bar_id];
    bars_size[bar_id] = math.max(bar.size[1], bars_size[bar_id] or 0);
    local max_width = bars_size[bar_id];

    bar.size = { calculate_width(max_width, value, max), bar.size[2] };
    bar.visible = visible;
  end
end


-- Set hud values.
events.on(resource("hud_open"), function()
  local old_data = {};
  local xp = 0;
  local attributes = {};

  local pid = hud.get_player();
  events.on(resource("player_tick"), function()
    local data = player_data.get_data(pid);

    xp = player_data.get_status(pid).xp;
    data.lvl = math.floor(experience.calc_lvl(xp)) or "";
    data.xp = math.floor(xp - experience.calc_total(data.lvl));

    local upd_queue = {};

    for key, value in pairs(data) do
      if not old_data[key] or old_data[key] ~= value then
        old_data[key] = value;
        upd_queue[key] = true;
      end
    end

    -- xp = player_data.get_status(pid).xp;

    attributes = player_data.get_attributes(pid);
    attributes.xp = experience.calc_next(data.lvl);

    for name, _ in pairs(upd_queue) do
      local value = data[name];
      local max = attributes[name];

      update_value(name, value, max);
    end
  end)
end)
