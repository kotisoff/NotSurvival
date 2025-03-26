local mp_api = require("mp_api/init")();
local resource = require "utility/resource_func";
local base_util = require "base:util";

events.on(resource("block_broken"), function(blockid, x, y, z, pid)
  ---@type { items: {item: number,count:number,vel:number[]}[] }
  local drop = {
    items = base_util.block_loot(blockid)
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
end)
