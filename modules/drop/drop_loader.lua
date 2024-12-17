local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

local loot_tables = require "drop/loot_tables";
local ResourceLoader = require "utility/resource_loader";

local drop_loader = ResourceLoader.new("drop_loader")
ResourceLoader.set_pack_id(PACK_ID);
drop_loader:scan_packs("data", { "not_survival" });

drop_loader:load_folders("loot_table/blocks");

events.on(resource("first_tick"), function()
  local log = drop_loader.logger;
  log:println("Adding loot table drops.")

  for packpath, itemdrops in pairs(drop_loader.packs) do
    log:info('Adding drops of "' .. packpath .. '"')

    local status = pcall(function()
      for _, drop in pairs(itemdrops) do
        loot_tables.blocks.set_drop(drop.name, drop.pools);
      end
    end)

    if not status then
      log:info('Some errors occured while loading pack \"' .. packpath .. '"')
      log:info('Check "' .. log:filepath() .. '" for more information.')
    end
  end

  loot_tables.blocks.set_handler("base:ice", function(blockid, x, y, z, pid)
    block.set(x, y, z, block.index("base:water"));

    return {};
  end)

  events.emit(resource("post_base_drop"))
end)

return drop_loader;
