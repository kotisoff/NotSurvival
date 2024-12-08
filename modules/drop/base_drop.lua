local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

loot_tables = require("drop/loot_tables")

get_block_item = loot_tables.blocks.get_block_item;

events.on(resource("first_tick"), function()
  print("Adding loot table drops");

  loot_tables.blocks.set_drop("base:grass", {});
  loot_tables.blocks.set_drop("base:water", {});

  loot_tables.blocks.set_drop("base:grass_block", { { 3, 1, { 1 } } });

  local tmp = {
    { get_block_item(resource("sapling")), 0.1,  { 1 } },
    { item.index(resource("apple")),       0.05, { 1 } },
    { item.index(resource("stick")),       0.02, { 1, 0.5 } }
  };
  loot_tables.blocks.set_drop("base:leaves", tmp);

  tmp = {
    { item.index(resource("coal")), 1, { 1, 0.4, 0.2, 0.1 } }
  };
  loot_tables.blocks.set_drop("base:coal_ore", tmp, { 1, 8 });

  tmp = {
    { get_block_item("base:sand"),   1,   { 1 } },
    { item.index(resource("flint")), 0.1, { 1 } }
  };
  loot_tables.blocks.set_drop("base:sand", tmp);

  loot_tables.blocks.set_handler("base:ice", function(blockid, x, y, z, pid)
    block.set(x, y, z, block.index("base:water"));

    return {
      items = {}
    }
  end)

  loot_tables.blocks.set_drop(PACK_ID .. ":dead_bush", { { item.index(resource("stick")), 1, { 0.5, 0.5 } } })

  loot_tables.blocks.set_drop("base:stone", { { get_block_item(resource("cobblestone")), 1, { 1 } } })

  events.emit(resource("post_drop_loading"))
end)
