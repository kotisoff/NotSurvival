local not_utils = require "shared/utils/not_utils"
local ns_events = require "shared/core/ns_events"
local death     = require "shared/player/stats/death"
local manager   = require "shared/player/data/manager"

---@param client neutron.class.client
local function _process_players_argument(player_arg, mp, client)
  if string.starts_with(player_arg, "@") then
    local players_mode = string.sub(player_arg, 2, 2)
    if players_mode == "a" then
      return table.keys(mp.sandbox.players.get_all())
    elseif players_mode == "s" then
      return { client.player.identity };
    end
  else
    ---@type neutron.class.player
    local target_player =
        table.filter(mp.sandbox.players.get_all():copy(),
          ---@param pl neutron.class.player
          function(_, pl) return pl.username == player_arg end
        )[0]

    if not target_player then
      return {}
    end

    return { target_player.identity };
  end
end

ns_events.on("first_tick", function()
  not_utils.multiplayer.as_server(function(mp, mode)
    mp.console.set_command("ns.kill: -> Убивает текущего игрока", {}, function(args, client)
      death.kill(client.player.pid, "ns.damage.fall");
    end)
  end)
end)
