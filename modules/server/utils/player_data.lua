local PACK_ID = "not_survival";

local module = {};

---@class PlayerData
local PlayerData = {
  gamemode = 0,
  health = 20,
  hunger = 20,
  saturation = 20,
  xp = 0,
  oxygen = 20,
  armor = 0
}

---@class PlayerAttributes
local PlayerAttributes = {
  health = 20,
  hunger = 20,
  saturation = 20,
  oxygen = 20,
  armor = 20
}

---@class PlayerStatus
---@field effects {identifier:string,level:number,time_left:number}[]
local PlayerStatus = {
  dead = false,
  effects = {}
}

---@param pid number
---@return { SAVED_DATA:table, ARGS:table }
local function get_component(pid)
  local entid = player.get_entity(pid);
  local entity = entities.get(entid);

  local component = entity.components[PACK_ID .. ":player"];
  component.ARGS.pid = pid;

  return component;
end

---Get player data. I.e.: health, hunger, etc.
---@param pid number
---@return PlayerData
function module.get_data(pid)
  local component = get_component(pid);
  return component.ARGS.data;
end

---Get player status. I.e.: death, effects
---@param pid number
---@return PlayerStatus
function module.get_status(pid)
  local component = get_component(pid);
  return component.ARGS.status;
end

---Get player attributes. I.e. max health, max hunger, etc.
---@param pid number
---@return PlayerAttributes
function module.get_attributes(pid)
  local component = get_component(pid);
  return component.ARGS.attributes;
end

---@return PlayerData
function module.new_data()
  ---@diagnostic disable-next-line: undefined-field
  return table.copy(PlayerData);
end

---@return PlayerStatus
function module.new_status()
  ---@diagnostic disable-next-line: undefined-field
  return table.copy(PlayerStatus);
end

---@return PlayerAttributes
function module.new_attributes()
  ---@diagnostic disable-next-line: undefined-field
  return table.copy(PlayerAttributes);
end

return module;
