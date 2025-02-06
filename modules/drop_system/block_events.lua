local api = require "api";
local exp = api.survival.experience;
local variables = api.player.variables;

local base_util = require "base:util"
local drop_util = require "drop_system/drop_util";

local log = api.utils.Logger.new("not_survival", "block_events");

events.on("not_survival:block_broken", function(blockid, x, y, z, pid)
  local status, data = pcall(variables.get_player_data, pid);
  if pid and (not status or data.gamemode == 1) then return end;

  local temp = drop_util.block_loot(blockid);

  local drop = {
    items = base_util.block_loot(blockid),
    experience = temp.experience,
    callback = temp.callback
  };

  local middle_pos = vec3.add({ x, y, z }, 0.5);

  for _, loot in ipairs(drop.items) do
    if loot.item then
      base_util.drop(middle_pos, loot.item, loot.count)
          .rigidbody:set_vel(vec3.spherical_rand(3));
    else
      log:println("Failed to get drop item id. Block: " .. block.name(blockid));
    end
  end

  if drop.experience > 0 then
    local orbs = math.min(math.random(10), drop.experience);
    for _ = 1, orbs do
      exp.summon(middle_pos, drop.experience / orbs).rigidbody:set_vel(vec3.spherical_rand(4));
    end
  end

  drop.callback(blockid, x, y, z, pid);
end)
