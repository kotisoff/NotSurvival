local utils = require "shared/utils/not_utils".utils;

local drop_util = {};

local function calculate_experience(loot)
  local exp_loot = loot.experience or { count = 0 };


  return exp_loot.count
      or math.round_to(
        math.rand(exp_loot.min or 0, exp_loot.max or 0),
        2
      )
end

---@return { experience: number, callback: fun(blockid: int, x: int, y: int, z: int, pid: int) }
function drop_util.block_loot(blockid)
  local loot = block.properties[blockid]["not_survival:loot"]
  if loot then
    local exp = calculate_experience(loot);
    local cb = function(...) end;

    if loot.callback then
      cb = utils.parse_function_string(loot.callback)
    end

    return { experience = exp, callback = cb };
  else
    return { experience = 0, callback = function(...) end };
  end
end

return drop_util;
