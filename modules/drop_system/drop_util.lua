---@diagnostic disable: undefined-field
local not_utils = require("api").utils.utils;

local drop_util = {};

local function calculate_experience(loot)
  local exp_loot = loot.experience;


  return exp_loot.count
      or not_utils.round_to(
        math.rand(exp_loot.min or 0, exp_loot.max or 0),
        100
      )
end

function drop_util.block_loot(blockid)
  local loot = block.properties[blockid]["not_survival:loot"]
  if loot then
    local exp = calculate_experience(loot);
    local cb = function(...) end;

    if loot.callback then
      cb = not_utils.parse_callback_string(loot.callback)
    end

    return { experience = exp, callback = cb };
  else
    return { experience = 0, callback = function(...) end };
  end
end

return drop_util;
