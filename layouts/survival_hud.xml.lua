---@diagnostic disable: inject-field
local player_data = require "shared/player/data/manager";
local experience = require "shared/utils/experience"
local ns_events = require "shared/core/ns_events"

local bars_size = {};

---@param max_width number
---@param value number
---@param max number
local function calculate_width(max_width, value, max)
  return math.floor(max_width * value / max);
end

---@param name str
---@param value number
---@param max number
local function is_visible(name, value, max)
  local more_than_zero = (value > 0);
  local oxygen_visible = not (name == "oxygen" and value >= max)

  return more_than_zero and oxygen_visible
end

---@param name str
---@param value number
---@param max? number
local function update_number_stat(name, value, max)
  local label_id = name .. "_label";
  local bar_id = name .. "_bar";

  local visible = is_visible(name, value, max or value);

  if document[label_id].exists then
    print('update label ' .. name);
    local label = document[label_id];

    local text = string.format("%s%s", value, max and "/" .. max or "");
    label.text = text;
    label.visible = visible;
  end
  if document[bar_id].exists then
    print('update bar ' .. name);
    local bar = document[bar_id];
    bars_size[bar_id] = math.max(bar.size[1], bars_size[bar_id] or 0);
    local max_width = bars_size[bar_id];

    bar.size = { calculate_width(max_width, value, max or value), bar.size[2] };
    bar.visible = visible;
  end
end


ns_events.on("__update_hud", function(pid, category, field, value)
  if category == "attributes" then return end;

  local attributes = table.copy(player_data.get_attributes(pid));

  if type(value) == "number" then
    if category == "status" and field == "xp" then
      local lvl = math.floor(experience.calc_level(value)) or "";
      update_number_stat("lvl", lvl);

      attributes.xp = experience.calc_next(lvl);
      value = math.floor(value - experience.calc_total(lvl));
    end

    update_number_stat(field, value, attributes[field]);
  end
end)
