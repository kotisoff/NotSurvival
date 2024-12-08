local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

require "survival/exp";
require "drop/loot_tables";
require "variables";
base_util = require "base:util"

events.on(resource("block_broken"), function(blockid, x, y, z, pid)
  local status, data = pcall(variables.get_player_data, pid);
  if not status or data.gamemode == 1 then return end;

  local drop = {
    item = block.get_picking_item(blockid),
    count = 1,
    experience = 0
  }

  drop = loot_tables.blocks.get_drop(blockid, x, y, z, pid) or drop;

  if drop.item ~= 0 then
    base_util.drop(vec3.add({ x, y, z }, 0.5), drop.item, drop.count).rigidbody:set_vel(vec3.spherical_rand(3));
  end

  if drop.experience > 0 then
    exp.give(pid, drop.experience);
  end
end)
