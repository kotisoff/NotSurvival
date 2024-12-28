local api = require "api";
local exp = api.exp;
local variables = api.variables;

local loot_tables = require "drop/loot_tables";
local base_util = require "base:util"

events.on("not_survival:block_broken", function(blockid, x, y, z, pid)
  local status, data = pcall(variables.get_player_data, pid);
  if pid and (not status or data.gamemode == 1) then return end;

  local drop = {
    items = { block.get_picking_item(blockid) },
    count = 1,
    experience = 0
  }

  drop = loot_tables.blocks.get_drop(blockid, x, y, z, pid) or drop;

  local middle_pos = vec3.add({ x, y, z }, 0.5);

  for _, value in pairs(drop.items) do
    if value ~= 0 then
      base_util.drop(middle_pos, value, drop.count)
          .rigidbody:set_vel(vec3.spherical_rand(3));
    end
  end

  if drop.experience > 0 then
    local orbs = math.random(6);
    for _ = 1, orbs do
      exp.summon(middle_pos, drop.experience / orbs).rigidbody:set_vel(vec3.spherical_rand(4));
    end
  end
end)
