---@diagnostic disable: undefined-field

local resource = require "utility/resource_func"

local log = require("utility/logger").new(PACK_ID, "not_utils");

function inventory.consume_selected(pid)
  local invid, slot = player.get_inventory(pid);
  local itemid, count = inventory.get(invid, slot);
  inventory.set(invid, slot, itemid, count - 1);
end

local not_utils = {};

---@param itemname string|number
---@return number|nil
function not_utils.index_item(itemname)
  if not itemname or type(itemname) == "number" then
    return itemname;
  end

  local itemid = nil;

  itemid = item.index(itemname)
  if not itemid then
    itemid = item.index(itemname .. ".item");
  end

  return itemid;
end

---@param num number
---@param accuracy number
---@return number
function not_utils.round_to(num, accuracy)
  return (math.floor(num) * accuracy) / accuracy
end

---@param chance number
---@param cb fun(): any
function not_utils.random_cb(chance, cb)
  if chance > math.random() then
    return cb()
  end
end

-- Coroutines

local coroutines = {};

---@param func fun()
function not_utils.create_coroutine(func)
  local co = coroutine.create(func);
  table.insert(coroutines, co);
end

---@param timesec number
---@param break_cb (fun(tempdata:any):boolean)|nil Break sleeping if true.
---@param cycle_task (fun(tempdata: any, time_passed: number))|nil Task repeating every tick.
---@return boolean
function not_utils.sleep_with_break(timesec, break_cb, cycle_task)
  local tempdata = {};
  break_cb = break_cb or function(a) return false end;
  cycle_task = cycle_task or function(a, t) end

  local start = time.uptime()
  while time.uptime() - start < timesec do
    if break_cb(tempdata) then return false end;
    cycle_task(tempdata, time.uptime() - start);
    coroutine.yield();
  end
  return true;
end

---@param timesec number
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

---Parse callback strings.
---@param prop string Property value. path or path@func or function(...) end
---@return fun(...)
function not_utils.parse_callback_string(prop)
  local callback = function(...) end;

  -- Callback as string function
  if string.starts_with(prop, "function(") then
    local cb, error = loadstring("(" .. prop .. ")()");
    if error then
      log:println(
        "Error occured while parsing property callback:\n" .. prop
      )
    elseif cb then
      callback = cb;
    end
  else
    -- Callback as script path and function name.
    local filepath, func_name = unpack(string.split(prop, "@"));
    local module = require(filepath);

    if func_name then
      callback = module[func_name];
    else
      callback = module;
    end
  end

  return callback;
end

return not_utils;
