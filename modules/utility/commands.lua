local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

local api = require "api";

local variables = api.variables;
local health = api.health;
local hunger = api.hunger;
local gamemode = api.gamemode;
local not_utils = api.utils;
local death = api.death;

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

            return set_var(pid, var, (variables.get_player_data(pid)[var] or 0) + add);
        end
    )

    console.add_command("surv.set_var player:sel=$obj.id var:str='health' val:int=1", "Set player variable",
        function(args, kwargs)
            return set_var(unpack(args));
        end
    )

    -- Drop hud

    console.add_command("surv.drop_menu", "Open drop hud",
        function()
            hud.show_overlay("not_survival:drop_loader_menu", false);
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

        local status, name = pcall(player.get_name, pid);
        if not status then name = tostring(pid) end;

        local invid, _ = player.get_inventory(pid);
        local itemid = index_item(itemname);
        if not itemid then return "No item found." end
        inventory.add(invid, itemid, count);
        return "Given player " .. name .. " " .. itemname .. "(" .. itemid .. ")" .. " x" .. count;
    end)

    console.add_command("kill player:sel=$obj.id", "Kill player", function(args)
        death.kill(args[1]);
    end)

    console.add_command("setname name:str", "Set your name", function(args)
        local pid = 0;
        local name = unpack(args);
        player.set_name(pid, name);
        return "Set name of player to " .. player.get_name(pid);
    end)

    console.add_command("heal player:sel=$obj.id", "Heal player", function(args)
        local pid = args[1];

        local attributes = variables.get_player_attributes(pid);

        health.heal(pid, attributes.health);
        hunger.add(pid, attributes.hunger, attributes.saturation);
    end)

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
