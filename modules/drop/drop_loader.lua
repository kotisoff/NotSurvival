local loot_tables = require "drop/loot_tables";
local ResourceLoader = require "utility/resource_loader";
local drop_converter = require "drop/drop_converter";

local drop_loader = ResourceLoader.new("drop_loader")
ResourceLoader.set_pack_id("not_survival");
drop_loader:scan_packs("data", { "not_survival" });

for res_path, _ in pairs(drop_loader.packs) do
  drop_converter.convert(res_path);
end

drop_loader:load_folders("loot_table/blocks");

events.on("not_survival:first_tick", function()
  local log = drop_loader.logger;
  for packpath, itemdrops in pairs(drop_loader.packs) do
    log:info('Adding drops of "' .. packpath .. '"')

    local status = pcall(function()
      ---@param drop Drop
      for _, drop in pairs(itemdrops) do
        if drop.type == "append" then
          loot_tables.blocks.append_drop(drop.name, drop.pools);
        elseif drop.type == "replace" then
          loot_tables.blocks.set_drop(drop.name, drop.pools);
        end
      end
    end)

    if not status then
      log:info('Some errors occured while loading pack \"' .. packpath .. '"')
      log:info('Check "' .. log:filepath() .. '" for more information.')
    end
  end
  log:print();

  loot_tables.blocks.append_handler("base:ice", function(blockid, x, y, z, pid)
    block.set(x, y, z, block.index("base:water"));

    ---@type DropPool
    return { items = {}, chance = 1, rolls = 1 };
  end)

  events.emit("not_survival:post_base_drop")
end)

return drop_loader;
