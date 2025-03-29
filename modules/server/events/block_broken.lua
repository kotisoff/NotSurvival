local mp_api = require("mp_api/init")();
local resource = require "utils/resource_func";
local base_util = require "base:util";
local drop_util = require "utils/drop_util"

local health = require "server/api/health";

events.on(resource("block_broken"), function(blockid, x, y, z, pid)
  local ns_drop = drop_util.block_loot(blockid);

  ---@type { items: {item: number,count:number,vel:number[]}[] }
  local drop = {
    items = base_util.block_loot(blockid),
    experience = ns_drop.experience
  }

  local pos = vec3.add({ x, y, z }, 0.5);

  for index, loot in ipairs(drop.items) do
    if loot.item then
      loot.vel = vec3.spherical_rand(3);
    else
      print("Failed to get drop item id. Block: " .. block.name(blockid));
      table.remove(drop.items, index);
    end
  end

  mp_api.server.echo("block_drop", pos, drop);
  print("Block " .. block.name(blockid) .. " broken at (" .. table.concat({ x, y, z }, ",") .. ")")

  ns_drop.callback(blockid, x, y, z, pid);
end)
