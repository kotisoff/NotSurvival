local not_utils = require("utility/utils");

local loot_tables = {};
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
---@param drop { name:string, pools:{id:string,chance:number,drop-chances:number[]|nil,experience:number[]|nil,rolls:number}[] }
function loot_tables.blocks.set_drop(blockname, drop)
  local index = string.gsub(blockname, ":", "__");
  loot_tables.blocks.data[index] = drop;
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
  local item = {};
  for _, itemdata in pairs(loot) do
    if itemdata.chance >= math.random() then
      for _ = 1, itemdata.rolls do
        item = item or itemdata;

        drop.item = not_utils.index_item(itemdata.id) or 0;

        for count, chance in pairs(itemdata["drop-chances"] or { 1 }) do
          if chance >= math.random() then
            drop.count = drop.count + count;
          end
        end

        drop.experience =
            drop.experience +
            not_utils.round_to(
              math.rand(unpack(itemdata.experience or { 0, 0 })),
              10
            )
      end
    end
  end

  if not item then return drop end;

  if drop.count == 0 then drop.item = 0 end;

  return drop;
end

return loot_tables
