local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

variables = {}

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

local DamageSource = {
    source = { 0, 0, 0 },
    type = "from nothing",
    amount = 0
}

-- Кучка говнокода для ковертации конфигов мира... Жесть.
local function migrateOldData(data)
    local player = table.copy(Player);

    for key, value in pairs(data.player) do
        if player[key] then
            player[key] = value;
        end
    end
    player.hunger = data.player.food;
    player.oxygen = data.player.air;
    player.xp = data.player.xp + exp.calc_total(data.player.lvl);

    local gm = 1;
    if data.config.survival then gm = 0 end;
    player.gamemode = gm;

    local max_values = table.copy(PlayerAttributes);
    for key, value in pairs(data.maxes) do
        if max_values[key] then
            max_values[key] = value;
        end
    end
    max_values.oxygen = data.maxes.air;
    max_values.hunger = data.maxes.food;
    max_values.saturation = data.maxes.food;

    return player, max_values;
end

---@param pid number
---@return { SAVED_DATA:table, ARGS:table }
local function get_player_component(pid)
    local entid = player.get_entity(pid);
    local entity = entities.get(entid);

    local component = entity.components[PACK_ID .. ":player"];
    component.set_player_id(pid);

    return component;
end


local data_file = pack.data_file(PACK_ID, "variables.json");
-- Deprecated. Migration use only
function variables.load()
    if not file.exists(data_file) then
        return false
    end

    print("Migrating from old config to entity data.");

    local data = json.parse(file.read(data_file));
    local player, attributes = migrateOldData(data);

    local component = get_player_component(0);

    component.ARGS.data = player;
    component.ARGS.attributes = attributes;
end

-- Deprecated. Migration use only
function variables.save()
    file.remove(data_file);
end

---Get player data.
---@param pid number
function variables.get_player_data(pid)
    local component = get_player_component(pid);
    return component.ARGS.data;
end

---Get player attributes.
---@param pid number
function variables.get_player_attributes(pid)
    local component = get_player_component(pid);
    return component.ARGS.attributes;
end

---Get damage type of player.
---@param pid number
function variables.get_player_damage(pid)
    local component = get_player_component(pid);
    return component.ARGS.damage_source;
end

function variables.new_player_data()
    return table.copy(Player);
end

function variables.new_player_attributes()
    return table.copy(PlayerAttributes);
end

function variables.new_player_damage()
    return table.copy(DamageSource);
end

return variables;
