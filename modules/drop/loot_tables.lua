-- Совсем скоро я это нечто вырежу к хуям. А пока пусть живёт...

loot_tables = {};
loot_tables.blocks = {
  data = {}
}

---@param blockname string
---@return number
function loot_tables.blocks.get_block_item(blockname)
  return block.get_picking_item(block.index(blockname));
end

---@param blockid number
---@return function|table|nil
local function get_block_loot_table(blockid)
  local index = string.gsub(block.name(blockid), ":", "__");
  return loot_tables.blocks.data[index];
end

---@param blockname string
---@param dropitems table Table of tables with numbers. 1 is itemid, 2 is chance, 3 is drop rate array.
---Will drop item table[1][1] with chance of table[1][2] (0 to 1) from 1 to element[1][3] items with element[1][3][index] chance (0 to 1).
---Drop priority is last item in table. Set rarest items in the end.
---Tip: For example you need to drop 3 items. Then set drop_rate to { 0, 0, 1 }.
---@param experience table|nil Experience count range. { 0, 10 } is from 0 to 10 xp points.
---Usage: loot_tables.blocks.set_drop("base:grass_block", { { 0, 1, { 1 } } }, { 0, 1 })
function loot_tables.blocks.set_drop(blockname, dropitems, experience)
  local index = string.gsub(blockname, ":", "__");
  loot_tables.blocks.data[index] = {
    items = dropitems,
    experience = experience or { 0, 0 }
  }
end

---Usage: loot_tables.blocks.set_handler("base:grass_block", function(blockid, x, y, z, pid) return { items = { { 0, 1, { 1 } } }, experience = { 0, 1 } } end)
---@param blockname string
---@param handler function
---@see loot_tables.blocks.set_drop
function loot_tables.blocks.set_handler(blockname, handler)
  local index = string.gsub(blockname, ":", "__");
  loot_tables.blocks.data[index] = handler;
end

---@param blockid number
---@param x number
---@param y number
---@param z number
---@param pid number
---@see loot_tables.blocks.set_handler
---@see loot_tables.blocks.set_drop
function loot_tables.blocks.get_drop(blockid, x, y, z, pid)
  local loot = get_block_loot_table(blockid);

  if not loot then return nil end;
  if type(loot) == "function" then
    loot = loot(blockid, x, y, z, pid);
  end

  local drop = {
    item = 0,
    experience = 0,
    count = 0
  }

  -- Take one of items from loot_table.
  local item = { 0, 0, { 0 } };
  for _, itemdata in pairs(loot.items) do
    if itemdata[2] >= math.random() then
      item = itemdata;
      drop.item = tonumber(itemdata[1])
    end
  end

  if not item then return drop end;

  -- Get drop count.
  for count, chance in pairs(item[3]) do
    if chance >= math.random() then
      drop.count = count;
    end
  end

  if drop.count == 0 then drop.item = 0 end;

  -- Get experience amount.
  drop.experience = math.random(unpack(loot.experience or { 0, 0 }));

  return drop;
end

return loot_tables
