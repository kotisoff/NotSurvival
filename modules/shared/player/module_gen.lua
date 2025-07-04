local data = require "shared/player/data"

local module = {}

---@param category ns.categories
---@param field ns.statusfield | ns.attributefield
---@param pid int
local function get(category, field, pid)
  return data.get(pid, category, field)
end

---@param category ns.categories
---@param field ns.statusfield | ns.attributefield
---@param pid int
local function set(category, field, pid, value)
  data.set_field(pid, category, field, value)
  require("server/lib/util/module_utils").update(pid, category, field, value)
end

-- =======================================
-- number funcs
-- =======================================

---@param field ns.attributefield
---@param pid int
---@return number
local function get_max(field, pid)
  return data.get_attributes(pid, field)
end

---@param field ns.attributefield
---@param pid int
---@param value number
local function set_max(field, pid, value)
  data.set_field(pid, "attributes", field, value)
  require("server/lib/util/module_utils").update(pid, "attributes", field, value)
end

---@param field ns.attributefield
---@param pid int
local function full(field, pid)
  set("data", field, pid, get_max(field, pid))
end

-- ========================================
-- Other funcs
-- ========================================

---@param category ns.categories
---@param field ns.attributefield | ns.statusfield
---@param pid int
---@param value number | table
local function num_or_table_add(category, field, pid, value)
  local cur = get(category, field, pid)
  if type(value) == type(cur) then
    if type(value) == "table" then
      cur = table.deep_copy(cur)
      table.insert(cur, value)
    elseif type(value) == "number" then
      cur = cur + value
    end
  end

  set(category, field, pid, cur)
end

---@param cat "status" | str
---@param field ns.statusfield
---@param pid int
local function bool_toggle(cat, field, pid)
  local cur = get(cat, field, pid)
  if type(cur) == "boolean" then
    set(cat, field, pid, not cur)
  end
end

-- ==========================srv============================
module.srv = {}

---@param cat ns.categories
---@param field ns.statusfield | ns.attributefield
---@return { get: (fun(pid: int): str), set: fun(pid: int, str: str) } | any
function module.srv.create_str(cat, field)
  return {
    get = function(pid) return get(cat, field, pid) end,
    set = function(pid, str) return set(cat, field, pid, str) end
  }
end

---@param cat ns.categories
---@param field ns.statusfield | ns.attributefield
---@return { get: (fun(pid: int): number), set: fun(pid: int, value: number), add: fun(pid: int, value: number) } | any
function module.srv.create_number(cat, field)
  return {
    get = function(pid) return get(cat, field, pid) end,
    set = function(pid, value) return set(cat, field, pid, value) end,
    add = function(pid, value) return num_or_table_add(cat, field, pid, value) end
  }
end

---@param cat ns.categories
---@param field ns.statusfield | ns.attributefield
---@return { get: (fun(pid: int): table), set: fun(pid: int, value: table), add: fun(pid: int, value: table) } | any
function module.srv.create_table(cat, field)
  return module.create_number(cat, field)
end

---@param cat "status" | str
---@param field ns.statusfield
---@return { get: (fun(pid: int): bool), set: fun(pid: int, flag: bool), toggle: fun(pid: int) } | any
function module.srv.create_bool(cat, field)
  return {
    get = function(pid) return get(cat, field, pid) end,
    set = function(pid, flag) return set(cat, field, pid, flag) end,
    toggle = function(pid) return bool_toggle(cat, field, pid) end
  }
end

---@param field ns.attributefield
---@return { get: (fun(pid: int): number), set: fun(pid: int, value: number), get_max: (fun(pid: int): number), set_max: fun(pid: int, value: number), full: fun(pid: int), add: fun(pid: int, value: number) } | any
function module.srv.create_data(field)
  local cat = "data"

  return {
    get = function(pid) return get(cat, field, pid) end,
    set = function(pid, value) return set(cat, field, pid, value) end,
    get_max = function(pid) return get_max(field, pid) end,
    set_max = function(pid, value) return set_max(field, pid, value) end,
    full = function(pid) return full(field, pid) end,
    add = function(pid, value) return num_or_table_add(cat, field, pid, value) end
  }
end

-- ==========================cli============================
module.cli = {}

---@param cat ns.categories
---@param field ns.statusfield | ns.attributefield
---@return { get: (fun(): any) } | any
function module.cli.create_getter(cat, field)
  return {
    get = function() return get(cat, field, hud.get_player()) end
  }
end

---@param cat ns.categories
---@param field ns.statusfield | ns.attributefield
---@return { get: (fun(): number) } | any
function module.cli.create_number(cat, field)
  return module.cli.create_getter(cat, field)
end

---@param cat ns.categories
---@param field ns.statusfield | ns.attributefield
---@return { get: (fun(): table) } | any
function module.cli.create_table(cat, field)
  return module.cli.create_getter(cat, field)
end

---@param cat "status" | str
---@param field ns.statusfield
---@return { get: (fun(): bool) } | any
function module.cli.create_bool(cat, field)
  return module.cli.create_getter(cat, field)
end

---@param field ns.attributefield
---@return { get: (fun(): number), get_max: (fun(): number) } | any
function module.cli.create_data(field)
  local cat = "data"

  return {
    get = function() return get(cat, field, hud.get_player()) end,
    get_max = function() return get_max(field, hud.get_player()) end
  }
end

return module
