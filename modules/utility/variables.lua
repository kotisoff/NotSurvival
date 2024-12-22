local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

local variables = {};

local Player = {
    gamemode = 0,
    health = 20,
    hunger = 20,
    saturation = 20,
    xp = 0,
    oxygen = 20,
    armor = 0
}

local PlayerAttributes = {
    health = 20,
    hunger = 20,
    saturation = 20,
    oxygen = 20,
    armor = 20
}

local PlayerStatus = {
    dead = false
}

local DamageSource = {
    source = { 0, 0, 0 },
    type = "from nothing",
    amount = 0
}

---@param pid number
---@return { SAVED_DATA:table, ARGS:table }
local function get_player_component(pid)
    local entid = player.get_entity(pid);
    local entity = entities.get(entid);

    local component = entity.components[PACK_ID .. ":player"];
    component.set_player_id(pid);

    return component;
end

---Get player data. I.e.: health, hunger, etc.
---@param pid number
function variables.get_player_data(pid)
    local component = get_player_component(pid);
    return component.ARGS.data;
end

---Get player status. I.e.: death
---@param pid number
function variables.get_player_status(pid)
    local component = get_player_component(pid);
    return component.ARGS.status;
end

---Get player attributes. I.e. max health, max hunger, etc.
---@param pid number
function variables.get_player_attributes(pid)
    local component = get_player_component(pid);
    return component.ARGS.attributes;
end

---Get damage source of player.
---@param pid number
function variables.get_player_damage(pid)
    local component = get_player_component(pid);
    return component.ARGS.damage_source;
end

function variables.new_player_data()
    return table.copy(Player);
end

function variables.new_player_status()
    return table.copy(PlayerStatus);
end

function variables.new_player_attributes()
    return table.copy(PlayerAttributes);
end

function variables.new_player_damage()
    return table.copy(DamageSource);
end

return variables;
