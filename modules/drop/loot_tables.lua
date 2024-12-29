local not_utils = require "utility/utils";

---@alias DropPool {items:string[],chance:number,count-chances:number[]|{chance:number,count:number}[]|nil,count:number|nil,experience:number[]|nil,rolls:number}
---@alias DropHandler fun(blockid:number, x:number, y:number, z:number, pid:number): DropPool

---@alias DropElement {chance:number,handler:DropHandler}|DropPool

local loot_tables = {};
loot_tables.blocks = {
  ---@type table<string, DropElement[]> Array of DropElements
  data = {}
}

--- UTIL FUNCTIONS

---@param blockname string
---@return number
function loot_tables.blocks.get_block_item(blockname)
  return block.get_picking_item(block.index(blockname));
end

---@param blockid number
---@return DropElement[]|nil
local function get_block_loot_table(blockid)
  local index = block.name(blockid);
  return loot_tables.blocks.data[index];
end

--- SET DROP

---REPLACES drop of block.
---@param blockname string
---@param handler DropHandler
---@param chance number|nil
function loot_tables.blocks.set_handler(blockname, handler, chance)
  chance = chance or 1;
  loot_tables.blocks.data[blockname] = { { chance = chance, handler = handler } };
end

---APPENDS drop of block.
---@param blockname string
---@param handler DropHandler
---@param chance number|nil
function loot_tables.blocks.append_handler(blockname, handler, chance)
  chance = chance or 1;
  if not loot_tables.blocks.data[blockname] then
    loot_tables.blocks.data[blockname] = {};
  end

  table.insert(loot_tables.blocks.data[blockname], { chance = chance, handler = handler });
end

---REPLACES drop of block.
---@param blockname string
---@param drop DropPool[]
function loot_tables.blocks.set_drop(blockname, drop)
  loot_tables.blocks.data[blockname] = drop;
end

---APPENDS drop of block.
---@param blockname string
---@param drop DropPool[]
function loot_tables.blocks.append_drop(blockname, drop)
  if not loot_tables.blocks.data[blockname] then
    loot_tables.blocks.data[blockname] = {};
  end

  for _, value in pairs(drop) do
    table.insert(loot_tables.blocks.data[blockname], value);
  end
end

---@param blockid number
---@param x number
---@param y number
---@param z number
---@param pid number
---@return {items:number[],experience:number,count:number}|nil
function loot_tables.blocks.get_drop(blockid, x, y, z, pid)
  local loot = get_block_loot_table(blockid);
  if not loot then return nil end;

  local drop = {
    items = {},
    experience = 0,
    count = 0
  }

  ---@type DropPool
  local pool = {};

  for _, pool_ in pairs(loot) do
    if pool_.chance >= math.random() then
      if pool_.handler then
        pool = pool_.handler(blockid, x, y, z, pid);
      else
        ---@type DropPool
        ---@diagnostic disable-next-line: assign-type-mismatch
        pool = pool_;
      end
    end
  end

  if not pool then return drop end;

  for _ = 1, pool.rolls or 0 do
    for _, value in pairs(pool.items) do
      local item = not_utils.index_item(value);
      if item then table.insert(drop.items, item); end;
    end

    if pool.count then
      drop.count = drop.count + pool.count;
    else
      local chances = pool["count-chances"] or { { chance = 1, count = 1 } }

      for key, data in pairs(chances) do
        local chance = 0;
        local count = 0;

        if type(data) == "number" then
          chance = data;
          count = key;
        elseif type(data) == "table" then
          chance = data.chance or 1;
          count = data.count or key;
        end

        if chance >= math.random() then
          drop.count = drop.count + count;
        end
      end
    end

    drop.experience =
        drop.experience +
        not_utils.round_to(
          math.rand(unpack(pool.experience or { 0, 0 })),
          10
        );
  end

  if drop.count == 0 then drop.items = {} end;

  return drop;
end

return loot_tables
