local server_utils = require "server/lib/util/server_utils"
local health       = require "shared/survival/health"
local death        = require "shared/survival/death"
local data         = require "shared/player/data_manager"

local _nu          = require "shared/utils/not_utils"
local mp           = _nu.multiplayer.api.server

events.on(server_utils.get_player_event(), function(pid)
  if data.get_status(pid).gamemode ~= 0 then return end

  if health.get(pid) <= 0 and not death.get(pid) then
    death.set(pid, true)

    local name = player.get_name(pid)
    local message = string.format("%s died.", name)
    mp.console.echo(message)
  end
end)
