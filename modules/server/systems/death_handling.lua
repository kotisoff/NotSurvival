local health          = require "shared/player/stats/health"
local death           = require "shared/player/stats/death"
local system_instance = require "shared/lib/system_instance"

local _nu             = require "shared/utils/not_utils"
local mp              = _nu.multiplayer.api.server

local Death_handler   = system_instance.new("ns.system.death_handler")

function Death_handler:should_update(id)
  return not death.is_invulnerable(id)
end

function Death_handler:update(pid, tps)
  if health.get(pid) <= 0 and not death.get(pid) then
    death.set(pid, true)

    local name = player.get_name(pid)
    local message = string.format("%s died.", name)
    mp.console.echo(message)
  end
end

return Death_handler;
