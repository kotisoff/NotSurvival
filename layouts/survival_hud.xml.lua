local resource = require "utils/resource_func";
local player_data = require "shared/player/data";
local experience = require "shared/lib/experience"

-- Generate hud keys.
events.on(resource("hud_open"), function()
  HUD_DATA = {};

  local data_keys = player_data.CategoryFields.data
  table.insert(data_keys, "lvl")
  table.insert(data_keys, "xp")

  for _, name in ipairs(data_keys) do
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
  local more_than_zero = (value > 0);
  local oxygen_visible = not (name == "oxygen" and value >= max)

  return more_than_zero and oxygen_visible
end

local function calculate_width(max_width, value, max)
  return math.floor(max_width * value / (max or value));
end

-- Set hud values.
events.on(resource("hud_open"), function()
  local player
  local xp

  local attributes


  local pid = hud.get_player();
  events.on(resource("player_tick"), function()
    player = player_data.get_data_dict(pid);

    ---@diagnostic disable-next-line: cast-local-type
    xp = player_data.get_status(pid, "xp");

    player.lvl = math.floor(experience.calc_lvl(xp)) or "";
    player.xp = math.floor(xp - experience.calc_total(player.lvl));

    attributes = player_data.get_attributes_dict(pid);
    attributes.xp = experience.calc_next(player.lvl);

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
end)
