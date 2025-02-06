---@diagnostic disable: undefined-field

local PACK_ID = "not_survival";

local variables = {};

---@class PlayerData
local Player = {
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

---@class DamageSource
local DamageSource = {
    source = { 0, 0, 0 },
    type = "from nothing",
    amount = 0
}

local component_cache = {};

local function is_cache_valid(pid)
    return component_cache[pid] and component_cache[pid].this
end

---@param pid number
---@return { SAVED_DATA:table, ARGS:table }
local function get_player_component(pid)
    local entid = player.get_entity(pid);
    local entity = entities.get(entid);

    if is_cache_valid(pid) then
        return component_cache[pid];
    end

    local component = entity.components[PACK_ID .. ":player"];
    component.set_player_id(pid);

    component_cache[pid] = component;

    return component;
end

---Get player data. I.e.: health, hunger, etc.
---@param pid number
---@return PlayerData
function variables.get_player_data(pid)
    local component = get_player_component(pid);
    return component.ARGS.data;
end

---Get player status. I.e.: death, effects
---@param pid number
---@return PlayerStatus
function variables.get_player_status(pid)
    local component = get_player_component(pid);
    return component.ARGS.status;
end

---Get player attributes. I.e. max health, max hunger, etc.
---@param pid number
---@return PlayerAttributes
function variables.get_player_attributes(pid)
    local component = get_player_component(pid);
    return component.ARGS.attributes;
end

---Get damage source of player.
---@param pid number
---@return DamageSource
function variables.get_player_damage(pid)
    local component = get_player_component(pid);
    return component.ARGS.damage_source;
end

---@return PlayerData
function variables.new_player_data()
    return table.copy(Player);
end

---@return PlayerStatus
function variables.new_player_status()
    return table.copy(PlayerStatus);
end

---@return PlayerAttributes
function variables.new_player_attributes()
    return table.copy(PlayerAttributes);
end

---@return DamageSource
function variables.new_player_damage()
    return table.copy(DamageSource);
end

return variables;
