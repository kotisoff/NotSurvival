---@diagnostic disable: undefined-field

local api = require "api";

local variables = api.player.variables;
local health = api.survival.health;
local hunger = api.survival.hunger;
local gamemode = api.game.gamemode;
local not_utils = api.utils.utils;
local death = api.survival.death;
local exp = api.survival.experience;
local effects = api.survival.effects;
local registry = api.registry;

local index_item = not_utils.index_item;

-- Change survival variables

function set_var(pid, var, val)
    local attributes = variables.get_player_attributes(pid);
    local playerdata = variables.get_player_data(pid);

    if not playerdata[var] then return 'No "' .. var .. '" variable found.' end
    if attributes[var] and val > attributes[var] or val < 0 then
        return "invalid value"
    end

    playerdata[var] = val;

    return var .. " now equals " .. val;
end

events.on("not_survival:hud_open", function()
    console.add_command("surv.add_var player:sel=$obj.id var:str='health' add:int=1", "Add to player variable",
        function(args, kwargs)
            local pid, var, add = unpack(args);

            return set_var(pid or 0, var, (variables.get_player_data(pid)[var] or 0) + add);
        end
    )

    console.add_command("surv.set_var player:sel=$obj.id var:str='health' val:int=1", "Set player variable",
        function(args, kwargs)
            local pid, var, val = unpack(args);
            return set_var(pid or 0, var, val);
        end
    )

    -- Event list

    console.add_command("event.list", "List of events", function(args, kwargs)
        local text = "Events:\n";
        for key, _ in pairs(events.handlers) do
            text = text .. key .. "\n"
        end
        return text;
    end)

    -- Minecraft-like commands.

    console.add_command("gamemode player:sel=$obj.id state:int", "Set game mode", function(args, kwargs)
        local pid, mode = unpack(args);

        local status, name = pcall(player.get_name, pid);
        if not status then name = tostring(pid) end;

        if gamemode.set_player_mode(pid, mode) then
            local gm = gamemode.modes[mode + 1] or {};
            return "Game mode of " .. name .. " set to " .. (gm.name or mode)
        else
            local text = { "Failed to change game mode." };
            for key, value in pairs(gamemode.modes) do
                table.insert(text, "  " .. tostring(key - 1) .. ". " .. value.name);
            end

            return table.concat(text, "\n");
        end
    end)

    console.add_command("give player:sel=$obj.id item:str count:int=1", "Give player item.", function(args)
        local pid, itemname, count = unpack(args);
        local name = player.get_name(pid);

        local invid, _ = player.get_inventory(pid);
        local itemid = index_item(itemname);
        if not itemid then return "No item found." end
        inventory.add(invid, itemid, count);
        return "Given player " .. name .. " " .. itemname .. "(" .. itemid .. ")" .. " x" .. count;
    end)

    console.add_command("kill player:sel=$obj.id", "Kill player", function(args)
        death.kill(args[1] or 0);
    end)

    console.add_command("heal player:sel=$obj.id", "Heal player", function(args)
        local pid = args[1];

        local attributes = variables.get_player_attributes(pid);

        health.heal(pid, attributes.health);
        hunger.add(pid, attributes.hunger, attributes.saturation);
    end)

    -- Experience

    console.add_command("xp.add player:sel=$obj.id amount:int", "Add player experience points", function(args)
        local pid, amount = unpack(args);
        exp.give(pid, amount);
        return "Given player " .. (pid or 0) .. " " .. amount .. " xp points."
    end)

    console.add_command("xp.drain player:sel=$obj.id amount:int", "Drain from player experience points", function(args)
        local pid, amount = unpack(args);
        exp.drain(pid, amount);
        return "Given player " .. (pid or 0) .. " " .. amount .. " xp points."
    end)

    console.add_command("summon entity:str x:num~pos.x=0 y:num~pos.y=100 z:num~pos.z=0",
        "Summon entity at pos",
        function(args)
            local entity, x, y, z = unpack(args);
            entities.spawn(
                entity,
                { x, y, z }
            )

            return "Entity " .. entity .. " summoned"
        end
    )

    -- Effect

    console.add_command("effects.give player:sel=$obj.id identifier:str level:num=1 duration:num=30",
        "Give player effect",
        function(args)
            local pid, identifier, level, duration = unpack(args);

            effects.give(pid, identifier, level, duration, true);
        end
    )

    console.add_command("effects.clear player:sel=$obj.id identifier:str=nil",
        "Clear effect(s)",
        function(args)
            local pid, identifier = unpack(args);


            effects.remove(pid, identifier, true);
        end
    )

    console.add_command("effects.list", "List of all effects registered",
        function(args)
            local effect_ids = { "Effects:" };
            for key, _ in pairs(registry:get_all_of(registry.TYPES.EFFECTS)) do
                table.insert(effect_ids, key);
            end

            console.log(table.concat(effect_ids, "\n"));
        end
    )

    console.add_command("effects.player player:sel=$obj.id",
        "List of effects of player",
        function(args)
            local pid = unpack(args);

            local text = { "Effects of player " .. player.get_name(pid) .. ":" }

            local status = variables.get_player_status(pid).effects;

            for index, effect in ipairs(status) do
                local symbols = { "\\", " " };
                if status[index + 1] then symbols = { "+", "|" } end;
                table.insert(text, symbols[1] .. "---**" .. effect.identifier .. "** (x" .. effect.level .. ")");
                table.insert(text, symbols[2] .. "   \\--- " .. effect.time_left .. " seconds left")
            end

            if #text == 1 then
                table.insert(text, "None");
            end

            console.log(table.concat(text, "\n"));
        end
    )

    -- Etc

    console.add_command("logdata player:sel=$obj.id", "Log player data", function(args)
        local pid = args[1];

        debug.print(variables.get_player_data(pid), variables.get_player_attributes(pid));
    end)

    console.add_command("spawnpoint player:sel=$obj.id", "Set player spawnpoint", function(args)
        local pid = unpack(args);
        local pos = vec3.round({ player.get_pos(pid) });
        player.set_spawnpoint(pid, unpack(pos));
        return "Set player spawnpoint at " .. table.concat(pos, " ");
    end)
end)

function stringifyArray(array, separator)
    if not separator then
        separator = " "
    end
    local a = "";
    for _, value in pairs(array) do
        a = a .. separator .. value;
    end
    return a;
end
