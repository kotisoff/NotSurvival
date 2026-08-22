local mp            = require "shared/lib/multiplayer".api.server;
local death         = require "shared/player/stats/death"
local manager       = require "shared/player/data/manager"
local DealKnockback = require "shared/net/messages/DealKnockback"

---@param player_arg str
---@param client neutron.class.client
local function __process_players_argument(player_arg, client)
  if string.starts_with(player_arg, "@") then
    local players_mode = string.sub(player_arg, 2, 2)
    if players_mode == "a" then
      return table.keys(mp.sandbox.players.get_all())
    elseif players_mode == "s" then
      return { client.player };
    else
      return {};
    end
  else
    ---@type neutron.class.player
    local target_player =
        table.filter(mp.sandbox.players.get_all():copy(),
          ---@param pl neutron.class.player
          function(_, pl) return pl.username == player_arg end
        )[0]

    if not target_player then return {} end;

    return { target_player };
  end
end

ns_events.on("first_tick", function()
  mp.console.set_command("ns.kill: -> Kill current player", {}, function(args, client)
    death.kill(client.player.pid, "ns.damage.fall");
  end)

  mp.console.set_command("ns.data_get: selector=<string>, path=[string] -> Get player data.", {},
    function(args, client)
      local pl = __process_players_argument(args.selector, client);

      if #pl ~= 1 then
        local msg = #pl > 1 and "Selected more than one player!" or "Player not found!";
        mp.console.tell(msg, client);
        return;
      end

      local selector = pl[1];

      local store = manager.get_store(selector.pid);
      local data = store;

      if args.path then
        local names = string.split(args.path, ".");
        for _, value in ipairs(names) do
          local num = tonumber(value);
          if tostring(num) == value then
            value = num;
          end

          data = data[value];
          if not data then
            mp.console.tell("Player data in path " .. args.path .. " not found!", client);
            return;
          end;
        end
      end

      local str_data;
      if type(data) == "table" then
        str_data = json.tostring(data);
      else
        str_data = tostring(data);
      end

      mp.console.tell(
        string.format("%s's data%s:\n%s",
          selector.identity, args.path and (" in " .. args.path) or "", str_data
        ),
        client
      );
    end)

  mp.console.set_command("ns.push: selector=<string>, vector=<table> -> Push player. Vector type: [ x, y, z ]", {},
    function(args, client)
      local vel = args.vector;

      if not is_array(vel) and #vel == 3 then
        mp.console.tell("Vector must be array of 3 elements", client);
        return;
      end;

      local players = __process_players_argument(args.selector, client);

      if #players == 0 then
        mp.console.tell("There are no players to push!", client);
        return;
      end

      for _, value in ipairs(players) do
        local _client = mp.sandbox.players.get_client(value);

        ---@cast DealKnockback neutron.server.messages.Message
        DealKnockback:tell(_client, { velocity = vel })
      end
      mp.console.tell("Push!", client);
    end)
end)
