local mp_api = require("mp_api/init")();
local base_util = require "base:util"

---@param drop { items: {item: number,count:number,vel:number[]}[] }
mp_api.client.on("block_drop", function(pos, drop)
  for _, loot in ipairs(drop.items) do
    local entity = base_util.drop(pos, loot.item, loot.count);

    if entity and entity.rigidbody then
      entity.rigidbody:set_vel(loot.vel);
    end
  end
end)
