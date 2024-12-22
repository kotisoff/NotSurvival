local PACK_ID = PACK_ID or "not_survival"; local function resource(name) return PACK_ID .. ":" .. name end;

function inventory.consume_selected(pid)
  local invid, slot = player.get_inventory(pid);
  local itemid, count = inventory.get(invid, slot);
  inventory.set(invid, slot, itemid, count - 1);
end

local not_utils = {};

function not_utils.index_item(itemname)
  local status = true;
  local itemid_or_err = 0;

  status, itemid_or_err = pcall(block.item_index, itemname);
  if not status then
    status, itemid_or_err = pcall(item.index, itemname)
  end;
  if not status then
    status, itemid_or_err = pcall(item.index, itemname .. ".item")
  end;

  if not status then
    return nil;
  end
  return itemid_or_err;
end

function not_utils.round_to(num, accuracy)
  return (math.floor(num) * accuracy) / accuracy
end

local coroutines = {};

function not_utils.create_coroutine(func)
  local co = coroutine.create(func);
  table.insert(coroutines, co);
end

---@param timesec number
---@param break_cb function|nil Break sleeping if true.
---@param cycle_task function|nil Task repeating every tick.
---@return boolean
function not_utils.sleep_with_break(timesec, break_cb, cycle_task)
  local tempdata = {};
  break_cb = break_cb or function(a) return false end;
  cycle_task = cycle_task or function(a, t) end

  local start = time.uptime()
  while time.uptime() - start < timesec do
    if break_cb(tempdata) then return false end;
    cycle_task(tempdata, time.uptime() - start);
    coroutine.yield()
  end
  return true;
end

function not_utils.sleep(timesec)
  local start = time.uptime()
  while time.uptime() - start < timesec do
    coroutine.yield();
  end
end

events.on(resource("world_tick"), function()
  for index, co in pairs(coroutines) do
    coroutine.resume(co);
    if coroutine.status(co) == "dead" then
      table.remove(coroutines, index);
    end
  end
end)

return not_utils;
