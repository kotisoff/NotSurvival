---@diagnostic disable: undefined-field

local resource = require "utility/resource_func"
local api = require "api";
local variables = api.player.variables;
local exp = api.survival.experience;

-- Generate hud keys.
events.on(resource("hud_open"), function()
  HUD_DATA = {};

  local data = variables.new_player_data();
  ---@diagnostic disable-next-line: inject-field
  data.lvl = 0;

  for name, _ in pairs(data) do
    local barname = name .. "_bar";

    local status_bar = pcall(function() return document[barname].pos end);
    local status_val = pcall(function() return document[name].pos end);

    if status_bar or status_val then
      HUD_DATA[name] = {
        has_label = status_val
      };
      if status_bar then
        HUD_DATA[name].barname = barname;
        HUD_DATA[name].size = document[barname].size[1]
      end
    end
  end
end)

local function is_visible(name, value, max)
  local less_than_zero = (value > 0);
  local oxygen_visible = not (name == "oxygen" and value >= max)

  return less_than_zero and oxygen_visible
end

local function calculate_width(max_width, value, max)
  return math.floor(max_width * value / (max or value));
end

-- Set hud values.
events.on(resource("world_tick"), function()
  local pid = hud.get_player();

  local player = table.copy(variables.get_player_data(pid)); -- Current client

  player.lvl = math.floor(exp.calc_lvl(player.xp));
  player.xp = math.floor(player.xp - exp.calc_total(player.lvl));


  local attributes = table.copy(variables.get_player_attributes(pid));
  attributes.xp = exp.calc_max(player.lvl);

  for label, data in pairs(HUD_DATA) do
    local barname = data.barname;

    local value = player[label];
    local max = attributes[label];

    local visible = is_visible(label, value, max);

    if barname then
      local max_width = data.size;
      local size = document[barname].size;
      local calculated_width = calculate_width(max_width, value, max);
      document[barname].size = { calculated_width, size[2] };

      document[barname].visible = visible;
    end

    if data.has_label then
      local text = tostring(math.floor(value));
      if max then
        text = text .. "/" .. max;
      end

      document[label].text = text;
      document[label].visible = visible;
    end
  end
end)
